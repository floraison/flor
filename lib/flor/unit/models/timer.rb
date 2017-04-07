
module Flor

  class Timer < FlorModel

    def to_trigger_message

      d = self.data(false)

      m = d['message']
      m['timer_id'] = self.id

      sm = d['m']

      {
        'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.onid,
        'bnid' => self.nid,
        'type' => self.type,
        'schedule' => self.schedule,
        'timer_id' => self.id,
        'message' => m,
        'sm' => sm
      }
    end

    def ntime_t

      @ntime_t ||= Time.parse(ntime)
    end
  end
end

