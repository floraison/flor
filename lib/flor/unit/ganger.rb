
module Flor

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

      #!! @unit.loader.tasker(d, name)
      !! (@unit.loader.tasker(d, 'tasker') || @unit.loader.tasker(d, name))
    end

    def task(executor, message)

      domain = message['exid'].split('-', 2).first
      tname = message['tasker']

      tconf =
        ( ! message['routed'] && @unit.loader.tasker(domain, 'tasker')) ||
        @unit.loader.tasker(domain, tname)
          #
          # TODO `.tasker(domain, 'ganger')`

      fail ArgumentError.new(
        "tasker #{tname.inspect} not found"
      ) unless tconf

      if ot = tconf['on_task']
        ot['_path'] = tconf['_path']
        tconf = ot
      end
        # remove at some point around flor 1.0

      message['tconf'] = tconf unless tconf['include_tconf'] == false

      message['vars'] = gather_vars(executor, tconf, message)

#      m =
#        message['point'] == 'detask' ?
#        :cancel :
#        :task

      r = @unit.runner.run(self, tconf, message)

      if is_a_message_array?(r)
        r
      else
        []
      end
    end

    def cancel(tasker_name, fei)

      # TODO use on_cancel || on_task

      fail NotImplementedError
    end

    def return(message)

      @unit.return(message)
    end

    protected

    def is_a_message_array?(o)

      o.is_a?(Array) &&
      o.first.is_a?(Hash) &&
      o.first['point'].is_a?(String)
    end

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

      # try to return before calling executor.vars(nid) which my be costly...

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

