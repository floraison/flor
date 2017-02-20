
module Flor

  class WaitList

    def initialize(unit)

      @unit = unit

      @mutex = Mutex.new
      @waiters = []

      @unit.instance_eval do
        def wait(exid, opts=true)
          @hooker['wlist'].wait(exid, opts)
        end
      end
    end

    def shutdown
    end

    def notify(executor, message)

      @mutex.synchronize do

        to_remove = []

        @waiters.each do |w|
          remove = w.notify(executor, message)
          to_remove << w if remove
        end

        @waiters -= to_remove

      end if message['consumed']

      [] # no new messages
    end

    def wait(exid, opts)

      exid, opts =
        if opts == true && exid == 'idle'
          [ nil, { wait: exid } ]
        elsif opts == true || opts.is_a?(String)
          [ exid, { wait: opts } ]
        else
          [ exid, opts ]
        end

      @mutex.synchronize do

        (@waiters << Waiter.new(exid, opts)).last

      end.wait
        # returns the response message
    end
  end
end

