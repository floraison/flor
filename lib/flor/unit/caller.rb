
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

    def ruby_call(service, conf, message)

      root = File.dirname(conf['_path'] || '.')

      Flor.h_fetch_a(conf, 'require').each { |pa|
        fail ArgumentError.new('".." not allowed in paths') if pa =~ /\.\./
        require(fjoin(root, pa)) }
      Flor.h_fetch_a(conf, 'load').each { |pa|
        fail ArgumentError.new('".." not allowed in paths') if pa =~ /\.\./
        load(fjoin(root, pa)) }

      #
      # initialize

      k = Flor.const_lookup(conf['class'] || conf['module'])

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

      cmd = h['cmd']

      m = encode(conf, message)
      out, _ = spawn(cmd, m)
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

    def spawn(cmd, data)

      i, o = IO.pipe # _ / stdout
      f, e = IO.pipe # _ / stderr
      r, w = IO.pipe # stdin / _

      pid = Kernel.spawn(cmd, in: r, out: o, err: e)
      w.write(data)
      w.close
      o.close
      e.close
      _, status = Process.wait2(pid)

      fail SpawnError.new(status, i.read, f.read) if status.exitstatus != 0

      [ i.read, status ]
    end

    class SpawnError < StandardError

      attr_reader :status, :out, :err

      def initialize(status, out, err)

        @status = status
        @out = out
        @err = err

        msg = err.strip.split("\n").last

        super("(code: #{status.exitstatus}, pid: #{status.pid}) #{msg}")
      end
    end

    def to_messages(o)

      case o
      when Hash then [ o ]
      when Array then o
      else []
      end
    end
  end
end

