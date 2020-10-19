# frozen_string_literal: true

module Flor

  class WaitList

    # NB: tasker configuration entries start with "wtl_"
    #
    # `wtl_default_timeout`:
    #   when #launch ing or #wait ing, set the default timeout, in seconds
    #
    # `wtl_row_frequency`:
    #   sleep time between row waiter checks, defaults to 1

    DEFAULT_TIMEOUT = Flor.env_i('FLOR_DEFAULT_TIMEOUT')

    def initialize(unit)

      @unit = unit
      @unit.hooker.add('wlist', self)

      @mutex = Mutex.new
      @msg_waiters = []
      @row_waiters = []

      @unit.instance_eval do
        def wait(exid, opts=true, more=nil)
          @hooker['wlist'].wait(exid, opts, more)
        end
      end

      @row_thread = nil
      @row_thread_status = nil
      @row_frequency = @unit.conf['wtl_row_frequency'] || 1
    end

    def shutdown

      @row_thread_status = :shutdown

      nil
    end

    def notify(executor, message)

      return [] unless message['consumed']
      return [] if @msg_waiters.empty?

      @mutex.synchronize do

        to_remove =
          @msg_waiters.each_with_object([]) do |w, a|
            remove = w.notify(executor, message)
            a << w if remove
          end

        @msg_waiters -= to_remove
      end

      [] # no new messages
    end

    def wait(exid, opts, more)

      exid, opts =
        if opts == true && ! Flor.is_exid?(exid)
          [ nil, { wait: exid } ]
        elsif opts == true || opts.is_a?(String)
          [ exid, { wait: opts } ]
        else
          [ exid, opts ]
        end
      opts.merge!(more) if more.is_a?(Hash)

      opts[:timeout] =
        nil if opts[:timeout] == true
      opts[:timeout] ||=
        (DEFAULT_TIMEOUT || @unit.conf['wtl_default_timeout'] || 5)

      @mutex.synchronize do

        waiter = Waiter.new(exid, opts)

        fail ArgumentError.new(
          "unit is stopped, it cannot wait for #{[ exid, opts ].inspect}"
        ) if waiter.msg_waiter? && @unit.stopped?

        waiters = [ @msg_waiters, @row_waiters ]
        ts = [ 'msg', 'row' ]
        if waiter.row_waiter?; waiters.reverse!; ts.reverse!; end

        fail ArgumentError.new(
          "cannot add a #{ts[0]} waiter, since there are already #{ts[1]} ones"
        ) if waiters[1].any?

        waiters.first << waiter

        start_row_thread if @row_waiters.any?

        waiter

      end.wait
        # returns the response message
    end

    protected

    def start_row_thread

      return if @row_thread_status == :shutdown

      @row_thread = nil if @row_thread && ! @row_thread.alive?
      @row_thread_status = :running

      @row_thread ||=
        Thread.new do
          loop do
            sleep(@row_frequency)
            break if [ :stop, :shutdown ].include?(@row_thread_status)
            break if @row_waiters.empty?
            check
          end
        end
    end

    def check

      @mutex.synchronize do

        to_remove = []

        rs = row_query_all

        @row_waiters.each do |w|
          remove = w.check(@unit, rs)
          to_remove << w if remove
        end

        @row_waiters -= to_remove
      end

    rescue => err

      @unit.logger.warn("#{self.class}#check()", err)
    end

    def row_query_all

      exes, ptrs =
        @row_waiters.inject([ [], [] ]) { |a, w|
          es, ps = w.to_query_hashes
          a[0].concat(es)
          a[1].concat(ps)
          a }

      [ row_query(:executions, exes), row_query(:pointers, ptrs) ]
    end

    def row_query(klass, hs)

      return [] if hs.empty?

      q = @unit.send(klass).where(hs.shift)
      hs.each { |h| q = q.or(h) }

      q.all
    end
  end
end

