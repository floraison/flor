
module Flor

  class Runner

    # NB: tasker configuration entries start with "rnr_"

    def initialize(unit)

      @unit = unit
    end

    def shutdown
    end

    def run(service, conf, message)

      return ruby_run(service, conf, message) if conf['class'] || conf['module']
      return cmd_run(service, conf, message) if conf['cmd']

      fail ArgumentError.new(
        "don't know how to run item at #{conf['_path']}")
    end

    protected

    def fjoin(root, path)

      root == '.' ? path : File.join(root, path)
    end

    def ruby_run(service, conf, message)

      root = File.dirname(conf['_path'])

      Flor.h_fetch_a(conf, 'require').each { |pa|
        fail ArgumentError.new('".." not allowed in paths') if pa =~ /\.\./
        require(fjoin(root, pa)) }
      Flor.h_fetch_a(conf, 'load').each { |pa|
        fail ArgumentError.new('".." not allowed in paths') if pa =~ /\.\./
        load(fjoin(root, pa)) }

      k = Flor.const_get(conf['class'] || conf['module'])

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

    def cmd_run(service, conf, message)

fail NotImplementedError
    end
  end
end

