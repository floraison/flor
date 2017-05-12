
module Flor

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

      [ "hook#{object_id}", opts, self, nil ]
    end


    def notify(executor, message)

      @unit.runner.run(executor, @h, message)
    end
  end
end

