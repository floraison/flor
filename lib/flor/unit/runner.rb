
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
          when 1 then k.new(conf)
          when 2 then k.new(conf, message)
          when 3 then k.new(service, conf, message)
          else k.new
          end
        end

      case o.method(:on).arity
      when 1 then o.on(message)
      when 2 then o.on(@h, message)
      when 3 then o.on(executor, @h, message)
      else o.on
      end
    end

    def cmd_run(service, conf, message)

fail NotImplementedError
    end
  end
end

