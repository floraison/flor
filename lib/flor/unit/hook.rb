
module Flor

  class Hook

    def initialize(exid, h)

      @exid = exid
      @h = h
    end

    def to_hook

      opts = {}
      opts[:consumed] = @h['consumed']
      opts[:point] = ha('points', 'point')
      opts[:heap] = ha('heaps', 'heap')
      opts[:heat] = ha('heats', 'heat')
      #opts[:name] = data['names']

      [ "hook#{object_id}", opts, self, nil ]
    end


    def notify(executor, message)

      return notify_ruby(executor, message) if @h['require']
      []
    end

    protected

    def ha(*keys)

      k = keys.find { |k| @h.has_key?(k) }
      v = k ? @h[k] : nil

      to_array(v)
    end

    def to_array(o, onnil=nil)

      return o if o.is_a?(Array)
      return o.split(',') if o.is_a?(String)

      if o == nil
        return nil if onnil == nil
        return onnil if onnil != :fail
      end

      fail ArgumentError.new("cannot turn instance of #{o.class} into an array")
    end

    def notify_ruby(executor, message)

      ha('require').each { |pa| require(pa) }

      k = @h['class'] || fail(ArgumentError.new('missing "class" argument'))
      k = Flor.const_get(k)

      hook =
        if k.class == Module
          k
        else
          case k.instance_method(:initialize).arity
          when 1 then k.new(@h)
          when 2 then k.new(@h, message)
          when 3 then k.new(executor, @h, message)
          else k.new
          end
        end

      case hook.method(:on).arity
      when 1 then hook.on(message)
      when 2 then hook.on(@h, message)
      when 3 then hook.on(executor, @h, message)
      else hook.on
      end
    end
  end
end

