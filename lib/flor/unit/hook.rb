
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

      opts = {}
      opts[:consumed] = @h['consumed']
      opts[:point] = Flor.h_fetch_a(@h, 'points', 'point', nil)
      opts[:nid] = Flor.h_fetch_a(@h, 'nids', 'nid', nil)
      opts[:heap] = Flor.h_fetch_a(@h, 'heaps', 'heap', nil)
      opts[:heat] = Flor.h_fetch_a(@h, 'heats', 'heat', nil)
      #opts[:name] = data['names']

      #correct_points(opts)
        #
        # Necessary since "cancel" gets interpreted as
        # [ '_proc', { 'proc' => 'cancel' }, @line ]
        # ...

      [ "hook#{object_id}", opts, self, nil ]
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
  end
end

