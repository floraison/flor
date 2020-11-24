# frozen_string_literal: true

module Flor

  class Waiter

    def initialize(exid, opts)

      serie, timeout, on_timeout =
        expand_args(opts)

      # TODO fail if the serie mixes msg_waiting with row_waiting...

      @exid = exid
      @serie = serie
      @timeout = timeout
      @on_timeout = on_timeout

      @queue = []
      @mutex = Mutex.new
      @var = ConditionVariable.new

      @executor = nil
    end

    ROW_PSEUDO_POINTS = %w[ status tag tasker var variable ].freeze
      # "tasker", not "task", since "task" is already a message point

    def row_waiter?

      @serie.find { |_, points|
        points.find { |po|
          pos = po.split(':')
          pos.length > 1 && ROW_PSEUDO_POINTS.include?(pos[0]) } }
    end

    def msg_waiter?

      @serie.find { |_, points|
        points.find { |po|
          ! ROW_PSEUDO_POINTS.include?(po.split(':').first) } }
    end

    def to_s

      "#{super[0..-2]}#{{ exid: @exid, timeout: @timeout }.inspect}>"
    end

    def notify(executor, message)

      @executor = executor
        # could be handy

      @mutex.synchronize do

        return false unless msg_match?(message)

        @serie.shift
        return false if @serie.any?

        @queue << [ executor, message ]
        @var.signal
      end

      true # serie over, remove me
    end

    def check(unit, rs)

      @mutex.synchronize do

        row = nil

        loop do

          break if @serie.empty?

          row = row_match?(unit, rs)
          return false unless row

          @serie.shift
        end

        @queue << [ unit, row ]
        @var.signal
      end

      true # serie over, remove me

    rescue => err

#puts "!" * 80; p err
      unit.logger.warn(
        "#{self.class}#check()", err, '(returning true, aka remove me)')

      true # remove me
    end

    def wait

      @mutex.synchronize do

        if @queue.empty?

          @var.wait(@mutex, @timeout)
            # will wait "in aeternum" if @timeout is nil

          if @queue.empty?
            fail RuntimeError.new(
              "timeout for #{self.to_s}, " +
              "msg_waiter? #{ !! msg_waiter?}, row_waiter? #{ !! row_waiter?}"
            ) if @on_timeout == 'fail'
            return { 'exid' => @exid, 'timed_out' => @on_timeout }
          end
        end

        @queue.shift[1]
      end
    end

    def to_query_hashes

      @serie
        .inject([ [], [] ]) { |a, (nid, points)|

          points.each do |point|

            ss = point.split(':')

            h = {}
            h[:exid] = @exid if @exid
            h[:nid] = nid if nid

            case ss[0]
            when 'status'
              h[:status] = ss[1]
              a[0] << h
            when 'tag', 'tasker', 'var', 'variable'
              t = ss[0]; t = 'var' if t == 'variable'
              h[:type] = t
              h[:name] = ss[1]
              h[:value] = ss[2] if ss[2]
              a[1] << h
            else
              fail ArgumentError, "cannot turn to query_hash, #{self.inspect}"
            end
          end

          a }
    end

    protected

    def msg_match?(message)

      mpoint = message['point']

      return false if @exid && @exid != message['exid'] && mpoint != 'idle'

      nid, points = @serie.first
      mnid = message['nid']

      return false if nid && mnid && nid != mnid

      return false unless points.find { |point|
        ps = point.split(':')
        next false if ps[0] != mpoint
        next false if ps[1] && ! message['tags'].include?(ps[1])
        true }

      true
    end

    def row_match?(unit, rs)

      nid, points = @serie.first

      row = nil

      points.find { |point|
        ps = point.split(':')
        row = send("row_match_#{ps[0]}?", unit, rs, nid, ps[1..-1]) }

      row
    end

    def row_match_status?(unit, rs, _, cdr)

      rs[0].find { |exe|
        (@exid == nil || exe.exid == @exid) &&
        exe.status == cdr.first }
    end

    def row_match_tag?(unit, rs, nid, (name, value))

      rs[1].find { |ptr|
        ptr.type == 'tag' &&
        (@exid == nil || ptr.exid == @exid) &&
        (nid == nil || ptr.nid == nid) &&
        (name == nil || ptr.name == name) &&
        (value == nil || ptr.value == value) }
    end

    def row_match_var?(unit, rs, nid, (name, value))

      rs[1].find { |ptr|
        ptr.type == 'var' &&
        (@exid == nil || ptr.exid == @exid) &&
        (nid == nil || ptr.nid == nid) &&
        (name == nil || ptr.name == name) &&
        (value == nil || ptr.value == value.to_s) }
    end
    alias row_match_variable? row_match_var?

    def row_match_tasker?(unit, rs, nid, (name, value))

      rs[1].find { |ptr|
        ptr.type == 'tasker' &&
        (@exid == nil || ptr.exid == @exid) &&
        (nid == nil || ptr.nid == nid) &&
        (name == nil || ptr.name == name) &&
        (value == nil || ptr.value == value) }
    end

    def expand_args(opts)

      owait = opts[:wait]
      otimeout = opts[:timeout]
      oontimeout = opts[:on_timeout] || opts[:ontimeout] || 'fail'

      case owait
      when nil, true
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          otimeout,
          oontimeout ]
      when Numeric
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          owait, # timeout
          oontimeout ]
      when String, Array
        [ parse_serie(owait), # serie
          otimeout,
          oontimeout ]
      else
        fail ArgumentError.new(
          "don't know how to deal with #{owait.inspect} (#{owait.class})")
      end
    end

    PT_REX = /[a-z]+(?::[^:|,\s]+){0,2}/.freeze

    def parse_serie(s)

      return s if s.is_a?(Array) && s.collect(&:class).uniq == [ Array ]

      (s.is_a?(String) ? s.split(';') : s)
        .collect { |ss|

          k = StringScanner.new(ss.strip)

          ni = k.scan(Flor::START_NID_REX)

          k.scan(/\s*/)

          pts = []; loop do
              pt = k.scan(PT_REX); break unless pt
              pts << pt
              k.scan(/\s*[|,]\s*/)
            end

          fail ArgumentError.new(
            "cannot parse #{ss.strip.inspect} wait directive") unless k.eos?

          [ ni, pts ] }
    end
  end
end

