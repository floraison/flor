# frozen_string_literal: true

module Flor

  class Timer < FlorModel

    #create_table :flor_timers do
    #
    #  primary_key :id, type: :Integer
    #  String :domain, null: false
    #  String :exid, null: false
    #  String :nid, null: false
    #  String :type, null: false # 'at', 'in', 'cron', 'every', ...
    #  String :schedule, null: false # '20141128.103239' or '00 23 * * *'
    #  String :ntime # next time
    #  File :content # JSON msg to trigger
    #  Integer :count, null: false
    #  String :status, null: false
    #  String :ctime, null: false
    #  String :mtime, null: false
    #  String :cunit
    #  String :munit
    #  String :onid, null: false
    #  String :bnid, null: false
    #
    #  index :exid
    #  index [ :exid, :nid ]
    #end

    def to_trigger_message

      d = self.data(false)

      m = d['message']
      m['timer_id'] = self.id

      sm = d['m']

      { 'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.onid,
        'bnid' => self.nid,
        'type' => self.type,
        'schedule' => self.schedule,
        'timer_id' => self.id,
        'message' => m,
        'sm' => sm }
    end

    def ntime_t

      @ntime_t ||= Time.parse(ntime)
    end
  end
end

