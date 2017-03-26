
module Flor

  class Timer < FlorModel

    def to_trigger_message

      m = self.data(false)['message']
      m['timer_id'] = self.id

      {
        'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.onid,
        'bnid' => self.nid,
        'type' => self.type,
        'schedule' => self.schedule,
        'timer_id' => self.id,
        'message' => m
      }
    end

    def ntime_t

      @ntime_t ||= Time.parse(ntime)
    end
  end
end

