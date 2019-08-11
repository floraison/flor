
module Flor

  # The caller calls Ruby or other scripts.
  #
  class Caller

    # NB: tasker configuration entries start with "cal_"

    def initialize(unit)

      @unit = unit
    end

    def shutdown
    end

    def call(service, conf, message)

      return ruby_call(service, conf, message) \
        if conf['class'] || conf['module']
      return cmd_call(service, conf, message) \
        if conf['cmd']

      fail ArgumentError.new("don't know how to call item at #{conf['_path']}")

    rescue => err

      [ Flor.to_error_message(message, err) ]
    end

    protected

    def conf

      @unit ? @unit.conf : {}
    end

    def fjoin(root, path)

      root == '.' ? path : File.join(root, path)
    end

    def do_require(conf, path)

      fail ArgumentError.new('".." not allowed in paths') \
        if path =~ /\.\./

      begin
        require(path)
        return
      rescue LoadError => le
      end

      root = File.dirname(conf['_path'] || '.')

      require(fjoin(root, path))
    end

    def do_load(conf, path)

      fail ArgumentError.new('".." not allowed in paths') \
        if path =~ /\.\./

      path += '.rb' unless path.match(/\.rb\z/)

      begin
        load(path)
        return
      rescue LoadError
      end

      root = File.dirname(conf['_path'] || '.')

      load(fjoin(root, path))
    end

    def ruby_call(service, conf, message)

      Flor.h_fetch_a(conf, 'require').each { |pa| do_require(conf, pa) }
      Flor.h_fetch_a(conf, 'load').each { |pa| do_load(conf, pa) }

      #
      # initialize

      k =
        case com = conf['class'] || conf['module']
        when String then Flor.const_lookup(com)
        when Class then com
        else fail ArgumentError.new("don't know how to call #{com.inspect}")
        end

      o =
        if k.class == Module
          k
        else
          case i = k.instance_method(:initialize).arity
          when 1, 2, 3 then k.new(
            *[ service, conf, message ][0, i])
          when -1 then k.new({
            service: service, configuration: conf, message: message })
          else k.new
          end
        end

      #
      # call

      p = message['point']
      ms = [ "on_#{p}", :on_message, :on, p ]
      ms = ms + [ :on_cancel, :cancel ] if p == 'detask'
      m = ms.find { |mm| o.respond_to?(mm) }

      fail(
        "#{k.class.to_s.downcase} #{k} doesn't respond to " +
        ms[0..-2].collect { |e| "##{e}" }.join(', ') + ", or ##{ms[-1]}"
      ) unless m

      r =
        case o.method(m).arity
        when 1 then o.send(m, message)
        when 2 then o.send(m, conf, message)
        when 3 then o.send(m, executor, conf, message)
        when -1 then o.send(m, {
          service: service, configuration: conf, message: message })
        else o.send(m)
        end

      #
      # reply

      to_messages(r)
    end

    def cmd_call(service, conf, message)

      h = conf.dup # shallow
      h['m'] = message
      h['f'] = message['payload']
      h['v'] = message['vars']
      h['tag'] = (message['tags'] || []).first

      m = encode(conf, message)
      out, _ = spawn(conf, m)
      r = decode(conf, out)

      to_messages(r)
    end

    def encode(context, message)

      coder =
        Flor.h_fetch(context, 'encoder', 'coder') ||
        Flor.h_fetch(conf, 'cal_encoder', 'cal_coder') ||
        '::JSON'

      Flor.const_get(coder)
        .dump(message)
    end

    def decode(context, data)

      coder =
        Flor.h_fetch(context, 'decoder', 'coder', 'encoder') ||
        Flor.h_fetch(conf, 'cal_decoder', 'cal_coder', 'cal_encoder') ||
        '::JSON'

      Flor.const_get(coder)
        .load(data)
    end

    def spawn(conf, data)

      t0 = Time.now

      cmd = conf['cmd']

      to = Fugit.parse(conf['timeout'] || '14s')
      to = to.is_a?(Fugit::Duration) ? to.to_sec : 14
      to = 0 if to < 0 # no timeout

      i, o = IO.pipe # _ / stdout
      f, e = IO.pipe # _ / stderr
      r, w = IO.pipe # stdin / _

      pid = Kernel.spawn(cmd, in: r, out: o, err: e)
      w.write(data)
      w.close
      o.close
      e.close

      _, status = Timeout.timeout(to) { Process.wait2(pid) }

      fail SpawnNonZeroExitError.new(conf, { to: to, t0: t0 }, status, i, f) \
        if status.exitstatus != 0

      [ i.read, status ]

    rescue => err

      Process.detach(pid) \
        if pid
      (Process.kill(9, pid) rescue nil) \
        unless Flor.no?(conf['on_error_kill'])

      raise err if err.is_a?(SpawnError)
      raise WrappedSpawnError.new(conf, { to: to, t0: t0, pid: pid }, err)

    ensure

      [ i, o, f, e, r, w ].each { |x| x.close rescue nil }
    end

    class SpawnError < StandardError

      attr_accessor :conf, :ctx

      def initialize(conf, ctx, msg)

        @conf = conf
        @ctx = ctx

        super(msg)
      end

      def details

        ha = Flor.yes?(@conf['on_error_hide_all'])
        hcd = Flor.yes?(@conf['on_error_hide_cmd'])
        hcf = Flor.yes?(@conf['on_error_hide_conf'])

        cd = (ha || hcd) ? '(hidden)' : @conf['cmd']
        cf = (ha || hcf) ? '(hidden)' : @conf.dup
        cf['cmd'] = '(hidden)' if hcd && cf.is_a?(Hash)

        d = {
          cmd: cd, conf: cf,
          timeout: ctx[:to],
          pid: ctx[:pid],
          start: Flor.tstamp(ctx[:t0]),
          duration: Fugit.parse(Time.now - ctx[:t0]).to_plain_s,
          cause: cause }

        add_details(d) \
          if respond_to?(:add_details)

        d
      end
    end

    class WrappedSpawnError < SpawnError

      attr_reader :cause

      def initialize(conf, ctx, err)

        @cause = err

        super(conf, ctx, "wrapped: #{err.class.name}: #{err.message}")

        set_backtrace(err.backtrace)
      end

      def add_details(details)

        details[:cause] = { kla: @cause.class.name, msg: @cause.message }
      end
    end

    class SpawnNonZeroExitError < SpawnError

      attr_reader :status, :out, :err

      def initialize(conf, ctx, status, stdout, stderr)

        @status = s = status
        @stdout = stdout.read
        @stderr = stderr.read

        ctx[:pid] ||= status.pid

        msg = @stderr.strip.split("\n").last

        super(conf, ctx, "(code: #{s.exitstatus}, pid: #{s.pid}) #{msg}")
      end

      def add_details(details)

        details[:status] = status.to_s
        details[:stdout] = @stdout
        details[:stderr] = @stderr
      end
    end

    def to_messages(o)

      case o
      when Hash then [ o ]
      when Array then o
      else []
      end
    end

    require 'flor/unit/caller_jruby' if RUBY_PLATFORM.match(/java/)
  end
end

