# frozen_string_literal: true

module Flor

  # ganger | ˈɡaNGər | \ noun British \ the foreman of a gang of laborers.
  #
  # The ganger receives the tasks from the flor executor, decides what
  # tasker will be invoked and hands it the task.
  #
  class Ganger

    # NB: tasker configuration entries start with "gan_"

    #RESERVED_NAMES = %w[ tag ]

    attr_reader :unit

    def initialize(unit)

      @unit = unit
    end

    def shutdown
    end

    # Used by flor when it looks up for a variable and finds nothing.
    # The last step is to ask the ganger if it knows about a tasker under
    # the given (domain and) name.
    #
    # If it returns true, flor knows there is a tasker under that name.
    #
    def has_tasker?(exid, name)

      #return false if RESERVED_NAMES.include?(name)

      d = Flor.domain(exid)

      !! (
        @unit.loader.tasker(d, 'ganger') ||
        @unit.loader.tasker(d, 'tasker') ||
        @unit.loader.tasker(d, name))
    end

    # Called by Flor::Scheduler. The ganger then has to hand the task
    # (the message) to the proper tasker.
    #
    def task(executor, message)

      domain = message['exid'].split('-', 2).first
      tname = message['tasker']

      tconf =
        ( ! message['routed'] &&
         (@unit.loader.tasker(domain, 'ganger', message) ||
          @unit.loader.tasker(domain, 'tasker', message))) ||
        @unit.loader.tasker(domain, tname, message)
#puts "=" * 80
#pp tconf
#puts "=" * 80

      fail ArgumentError.new(
        "tasker #{tname.inspect} not found"
      ) unless tconf

      if tconf.is_a?(Array)

        points = [ nil, message['point'] ]
        points << 'detask' if points.include?('cancel')

        tconf = tconf.find { |h| points.include?(h['point']) }
      end

      fail ArgumentError.new(
        "tconf #{tconf.inspect} not a hash"
      ) unless tconf.is_a?(Hash)

      message['tconf'] = tconf unless tconf['include_tconf'] == false

      message['vars'] = gather_vars(executor, tconf, message)

      m = Flor.dup_message(message)
        #
        # the tasker gets a copy of the message (and it can play with it
        # to its heart content), meanwhile the message is handed to the
        # "post" notifiers.

      @unit.caller.call(self, tconf, m)
        #
        # might return a re-routing message,
        # especially if it's a domain tasker
    end

    # Called by the tasker implementations when they're done with a task
    # and want to hand it back to flor. It might be a failure message.
    #
    def return(message)

      @unit.return(message)
    end

    protected

    def var_match(k, filter)

      filter.each { |f| return true if (f.is_a?(String) ? k == f : f.match(k)) }
      false
    end

    def expand_filter(f)

      return f unless f.is_a?(Array)

      f.collect { |e|
        if e.is_a?(String)
          e
        elsif e.is_a?(Array) && e[0] == '_rxs' && e[1].is_a?(String)

          s = e[1]
          li, ri = s.index('/'), s.rindex('/')
          tail = s[ri + 1..-1]
          ops =
            (tail.index('i') ? Regexp::IGNORECASE : 0) |
            (tail.index('x') ? Regexp::EXTENDED : 0)
          Regexp.new(s[li + 1..ri - 1], ops)
        else
          nil
        end
      }.compact
    end

    # By default, taskers don't see the flor variables in the execution.
    # If 'include_vars' or 'exclude_vars' is present in the configuration
    # of the tasker, some or all of the variables are passed.
    #
    def gather_vars(executor, tconf, message)

      # try to return before a potentially costly call to executor.vars(nid)

      return nil if (tconf.keys & %w[ include_vars exclude_vars ]).empty?
        # default behaviour, don't pass variables to taskers

      iv = expand_filter(tconf['include_vars'])
      return nil if iv == false

      ev = expand_filter(tconf['exclude_vars'])
      return {} if ev == true

      vars = executor.vars(message['nid'])

      return vars if iv == true

      vars = vars.select { |k, v| var_match(k, iv) } if iv
      vars = vars.reject { |k, v| var_match(k, ev) } if ev

      vars
    end
  end
end

