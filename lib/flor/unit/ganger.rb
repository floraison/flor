
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

    def has_tasker?(exid, name)

      #return false if RESERVED_NAMES.include?(name)

      d = Flor.domain(exid)

      !! (
        @unit.loader.tasker(d, 'ganger') ||
        @unit.loader.tasker(d, 'tasker') ||
        @unit.loader.tasker(d, name))
    end

    def task(executor, message)

      message = message.dup
        #
        # work with a shallow copy of the message, the original message
        # will get passed to the "post" hooks, while this shallow copy
        # gets passed to the tasker

      domain = message['exid'].split('-', 2).first
      tname = message['tasker']

      tconf =
        ( ! message['routed'] &&
         (@unit.loader.tasker(domain, 'ganger', message) ||
          @unit.loader.tasker(domain, 'tasker', message))) ||
        @unit.loader.tasker(domain, tname, message)

      fail ArgumentError.new(
        "tasker #{tname.inspect} not found"
      ) unless tconf

      if tconf.is_a?(Array)
        tconf =
          tconf.find { |h| h['point'] == message['point'] } ||
          tconf.find { |h| h['point'] == nil }
        tconf ||=
          tconf.find { |h| h['point'] == 'cancel' } \
            if message['point'] == 'detask'
      end

      message['tconf'] = tconf unless tconf['include_tconf'] == false

      message['vars'] = gather_vars(executor, tconf, message)

      @unit.caller.call(self, tconf, message)
        #
        # might return a re-routing message,
        # especially if it's a domain tasker
    end

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

