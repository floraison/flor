
module Flor

  class Waiter

    def initialize(exid, opts)

      serie, timeout, on_timeout, repeat =
        expand_args(opts)

      @exid = exid
      @original_serie = repeat ? Flor.dup(serie) : nil
      @serie = serie
      @timeout = timeout
      @on_timeout = on_timeout

      @queue = []
      @mutex = Mutex.new
      @var = ConditionVariable.new
    end

    def to_s

      "#{super[0..-2]}#{
        { exid: @exid,
          original_serie: @original_serie,
          timeout: @timeout }.inspect
      }>"
    end

    def notify(executor, message)

      @mutex.synchronize do

        return false unless match?(message)

        @serie.shift
        return false unless @serie.empty?

        @queue << [ executor, message ]
        @var.signal
      end

      # then...
      # returning false: do not remove me, I want to listen/wait further
      # returning true: remove me

      return true unless @original_serie

      @serie = Flor.dup(@original_serie) # reset serie

      false # do not remove me
    end

    def wait

      @mutex.synchronize do

        if @queue.empty?

          @var.wait(@mutex, @timeout)
            # will wait "in aeternum" if @timeout is nil

          if @queue.empty?
            fail RuntimeError.new(
              "timeout for #{self.to_s}"
            ) if @on_timeout == 'fail'
            return { 'exid' => @exid, 'timed_out' => @on_timeout }
          end
        end

        @queue.shift[1]
      end
    end

    protected

    def match?(message)

      mpoint = message['point']

      return false if @exid && @exid != message['exid'] && mpoint != 'idle'

      nid, points = @serie.first
      mnid = message['nid']

      return false if nid && mnid && nid != mnid
      return false if ! points.include?(mpoint)

      true
    end

    def expand_args(opts)

      owait = opts[:wait]
      orepeat = opts[:repeat] || false
      otimeout = opts[:timeout]
      oontimeout = opts[:on_timeout] || opts[:ontimeout] || 'fail'

      case owait
      when nil, true
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          otimeout,
          oontimeout,
          orepeat ]
      when Numeric
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          owait, # timeout
          oontimeout,
          orepeat ]
      when String, Array
        [ parse_serie(owait), # serie
          otimeout,
          oontimeout,
          orepeat ]
      else
        fail ArgumentError.new(
          "don't know how to deal with #{owait.inspect} (#{owait.class})")
      end
    end

    def parse_serie(s)

      return s if s.is_a?(Array) && s.collect(&:class).uniq == [ Array ]

      (s.is_a?(String) ? s.split(';') : s)
        .collect { |s|
          ni, pt = s.strip.match(/\A([0-9_\-]+)? *([a-z|, ]+)\z/)[1, 2]
          [ ni, pt.split(/[|,]/).collect(&:strip) ]
        }
    end
  end
end

