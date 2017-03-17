
module Flor

  class WaitList

    # NB: tasker configuration entries start with "wtl_"
    #
    # `wtl_default_timeout`:
    #   when #launch ing or #wait ing, set the default timeout, in seconds

    DEFAULT_TIMEOUT = Flor.env_i('FLOR_DEFAULT_TIMEOUT')

    def initialize(unit)

      @unit = unit
      @unit.hooker.add('wlist', self)

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

      opts[:timeout] =
        nil if opts[:timeout] == true
      opts[:timeout] ||=
        (DEFAULT_TIMEOUT || @unit.conf['wtl_default_timeout'] || 5)

      @mutex.synchronize do

        (@waiters << Waiter.new(exid, opts)).last

      end.wait
        # returns the response message
    end
  end
end

