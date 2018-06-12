
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

      k = Flor.const_lookup(conf['class'] || conf['module'])

      o =
        if k.class == Module
          k
        else
          case k.instance_method(:initialize).arity
          when 1 then k.new(service)
          when 2 then k.new(service, conf)
          when 3 then k.new(service, conf, message)
          when -1 then k.new({
            service: service, configuration: conf, message: message })
          else k.new
          end
        end

      p = message['point']
      m = :on
      m = "on_#{p}" if ! o.respond_to?(m)
      m = p if ! o.respond_to?(m)
      m = :cancel if m == 'detask' && ! o.respond_to?(m)

      fail(
        "#{k.class.to_s.downcase} #{k} doesn't respond to on, on_#{p} or #{p}"
      ) if ! o.respond_to?(m)

      case o.method(m).arity
      when 1 then o.send(m, message)
      when 2 then o.send(m, conf, message)
      when 3 then o.send(m, executor, conf, message)
      when -1 then o.send(m, {
        service: service, configuration: conf, message: message })
      else o.send(m)
      end
    end

    def cmd_call(service, conf, message)

      h = conf.dup # shallow
      h['m'] = message
      h['f'] = message['payload']
      h['v'] = message['vars']
      h['tag'] = (message['tags'] || []).first

      cmd = h['cmd']

      m = encode(conf, message)
      status, data = spawn(cmd, m)
      d = decode(conf, data)

      if status.exitstatus != 0
# TODO answer with "point" => "failed" message
puts ">>> #{status.inspect} <<<"
      end

      d['point'] = 'receive'

      [ d ] # TODO really go for multiple messages?
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

      i, o = IO.pipe
      r, w = IO.pipe

      pid = Kernel.spawn(cmd, in: r, out: o)
      w.write(data)
      w.close
      o.close
      _, status = Process.wait2(pid)

      [ status, i.read ]
    end
  end
end

