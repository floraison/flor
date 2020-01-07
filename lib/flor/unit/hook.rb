
module Flor

  # Used by Flor::Loader to prepare hooks from hooks.json files.
  #
  class Hook

    def initialize(unit, exid, h)

      @unit = unit
      @exid = exid
      @h = h
    end

    def to_hook

      @unit.loader.require(@h)

      if @h['class']
        class_to_hook
      elsif @h['instance']
        instance_to_hook
      else
        classical_to_hook
      end
    end

    def notify(executor, message)

      @unit.caller.call(executor, @h, message)
    end

  # Avoid the proc/cancel problem upstreams in ConfExecutor, by ignoring
  # non-core procedures, keeping this around for now
  #
#    protected
#
#    def correct_points(opts)
#
#      pts = opts[:point]; return unless pts
#
#      opts[:point] =
#        Flor.is_tree?(pts) ?
#        correct_point(pts) :
#        pts.collect { |pt| correct_point(pt) }
#    end
#
#    def correct_point(point)
#
#      return point[1]['proc'] if point.is_a?(Array) && point[0] == '_proc'
#      point
#    end

    def extract_filters(h)

      r = {}
      r[:consumed] = h['consumed']
      r[:point] = Flor.h_fetch_a(h, 'points', 'point', nil)
      r[:nid] = Flor.h_fetch_a(h, 'nids', 'nid', nil)
      r[:heap] = Flor.h_fetch_a(h, 'heaps', 'heap', nil)
      r[:heat] = Flor.h_fetch_a(h, 'heats', 'heat', nil)
      #opts[:name] = data['names']

      r
    end

    def class_to_hook

      i = Flor::Hook.instantiate(@unit, @h['class'])

      h = @h.dup
      h.merge!(Flor.to_string_keyed_hash(i.opts)) if i.respond_to?(:opts)
      opts = extract_filters(h)

      [ "hooc#{object_id}", opts, i, nil ]
    end

    def instance_to_hook

      i = @h['instance']

      h = @h.dup
      h.merge!(Flor.to_string_keyed_hash(i.opts)) if i.respond_to?(:opts)
      opts = extract_filters(h)

      [ "hooi#{object_id}", opts, i, nil ]
    end

    def classical_to_hook

      opts = extract_filters(@h)

      #correct_points(opts)
        #
        # Necessary since "cancel" gets interpreted as
        # [ '_proc', { 'proc' => 'cancel' }, @line ]
        # ...

      [ "hook#{object_id}", opts, self, nil ]
    end

    class << self

      def instantiate(unit, hook_class)

        c =
          case hook_class
          when String then Flor.const_get(hook_class)
          else hook_class
          end
        a =
          case i = c.instance_method(:initialize).arity
          when 0, 1 then [ unit ][0, i]
          else []
          end

        c.new(*a)
      end
    end
  end
end

