# frozen_string_literal: true


module Flor

  # TODO ::Logger has a formatting callback

  # No log rotation,
  # just dump to stdout (or stderr), see https://12factor.net/logs

  class Logger

    # NB: logger configuration entries start with "log_"

    LEVELS_I = %w[ DEBUG INFO WARN ERROR FATAL UNKNOWN ].freeze

    def initialize(unit)

      @unit = unit
      @unit.hooker.add('logger', self)

      @out = Flor::Logger::Out.prepare(@unit)

      @uni = @unit.identifier

      self.level = @unit.conf['log_level'] || 1
    end

    def opts; { consumed: true }; end

    def shutdown

      @out.close
    end

    attr_reader :level

    def level=(i)

      original = i
      i = LEVELS_I.index(i.to_s.upcase) unless i.is_a?(Integer)

      fail ArgumentError.new(
        "'log_level' must be between 0 (DEBUG) and 4 (FATAL). " +
        "#{original.inspect} not acceptable"
      ) unless i.is_a?(Integer) && i > -1 && i < 6

      @level = i
    end

    def debug(*m); log(:debug, *m); end
    def info(*m); log(:info, *m); end
    def warn(*m); log(:warn, *m); end
    def error(*m); log(:error, *m); end
    def fatal(*m); log(:fatal, *m); end
    def unknown(*m); log(:unknown, *m); end

    def log(level, *elts)

      lvl = level.to_s.upcase
      lvi = LEVELS_I.index(lvl)
      return if lvi < @level

      n = Time.now.utc
      stp = Flor.tstamp(n)

      dbi =
        case @unit.storage.db.to_s
        when /SQLite/ then @unit.storage.db.uri
        else ''
        end
      dbi = ' ' + dbi if dbi.length > 0

      txt = elts.collect(&:to_s).join(' ')

      err = find_err(elts)

      head = "#{stp} #{@uni}#{dbi} #{lvl} "

      if err
        dig = lvl[0, 1] + Digest::MD5.hexdigest(head + txt)[0, 4]
        @out.puts(head + dig + ' ' + txt)
        err.backtrace.each { |lin| @out.puts("  #{dig} #{@uni} #{lin}") }
      else
        @out.puts(head + txt)
      end
    end

    def notify(executor, msg)

      if msg['rewritten'] && @unit.conf['log_tree_rw']

        @out <<
          Flor.to_compact_tree_s(
            msg['rewritten'], msg['nid'],
            ind: 6, title: "rewrote #{msg['exid']} #{msg['nid']}")
        @out << "\n" <<
          Flor.to_compact_tree_s(
            msg['tree'], msg['nid'],
            ind: 6, title: "into #{msg['exid']} #{msg['nid']}",
            close: true)
      end

      @out.puts(
        Flor.message_to_one_line_s(executor, msg, out: @out)
      ) if @unit.conf['log_msg'] && msg['point'] != 'end'

      [] # we're only logging, do not queue further messages
    end

    def db_log(level, msg)

      return unless @unit.conf['log_sto']
#return unless msg.match(/flor_timers/)
#p Time.now

      _c = Flor.colours(out: @out)

      #m = msg.match(/ (INSERT|UPDATE) .+ (0?[xX]'?[a-fA-F0-9]+'?)/)
      #msg = msg.sub(m[2], "#{m[2][0, 14]}(...len#{m[2].length})") if m
        #
        # with a fat blob, may lead to memory problems very quickly, hence:
        #
      msg = summarize_blob(msg)

      msg = "#{_c.dg}#{msg}"
      msg = msg.gsub(/\b(INSERT|UPDATE)\b/) { |m| "#{_c.rs}#{m}#{_c.dg}" }

      tim = Time.now.utc.strftime('%T.%L') # HH:MM:SS.123
      dbi = @unit.storage.db.object_id.to_s(16)
      tid = Thread.current.object_id.to_s(16)
      lvl = level.upcase

      @out.puts(
        "#{_c.blg}sto#{_c.rs} " +
        "#{tim} #{_c.dg}db#{dbi} th#{tid} " +
        "#{_c.rs}#{lvl}#{_c.rs} #{msg}#{_c.rs}")
    end

    def size_to_s(s)

      "%.2fk" % (s.to_f / 1024)
    end

    def log_run_start(executor)

      return unless @unit.conf['log_run']

      execution = executor.execution
      _c = Flor.colours(out: @out)
      s = StringIO.new

      s << _c.dg
      s << "    /--- #{_c.lg}run starts#{_c.dg} "
      s << "#{executor.class} #{executor.object_id} #{execution['exid']}"
      s << "\n    |   "; s << Flor.to_dnc(thread: Thread.current.object_id)
      s << "\n    |   "; s << Flor.to_dnc(
        counters: execution['counters'],
        nodes: execution['nodes'].size,
        execution_size: size_to_s(execution['size']))
      s << _c.rs

      @out.puts(s.string)
    end

    def log_run_end(executor, tstamp, duration)

      return unless @unit.conf['log_run']

      execution = executor.execution
      exid = executor.exid

      _c = Flor.colours(out: @out)
      s = StringIO.new

      s << _c.dg
      s << "    |   run ends #{self.class} #{self.object_id} #{exid}"
      #s << "\n    |   "; s << Flor.to_dnc(started: tstamp, took: duration)
      s << "\n    |   "; s << Flor.to_dnc(started: tstamp, took: duration)
      s << "\n    |   "; s << Flor.to_dnc(
        thread: Thread.current.object_id,
        consumed: executor.consumed.count,
        traps: executor.traps.count)
      s << "\n    |   "; s << Flor.to_dnc(
        #own_traps: @traps.reject { |t| t.texid == nil }.size, # FIXME
        counters: execution['counters'],
        nodes: execution['nodes'].size,
        execution_size: size_to_s(execution['size']))
      if @unit.archive
        s << "\n    |   "
        s << Flor.to_dnc(archive_size: (@unit.archive[exid].size rescue '???'))
      end
      s << "\n    \\--- ."
      s << _c.rs

      @out.puts(s.string)
    end

    def log_err(executor, message, opts={})

      return unless @unit.conf['log_err']

      s = Flor.msg_to_detail_s(executor, message, opts.merge(flag: true))
      @out.puts(s) if s
    end

    def log_src(source, opts, log_opts={})

      return unless @unit.conf['log_src']

      @out.puts(Flor.src_to_s(source, opts, log_opts))
    end

    def log_tree(tree, nid='0', opts={})

      return unless @unit.conf['log_tree']

      @out.puts(Flor.tree_to_s(tree, nid, opts.merge(out: @out)))
    end

    protected

    BLOB_CHARS = (('a'..'f').to_a + ('A'..'F').to_a + ('0'..'9').to_a).freeze

    def summarize_blob(message)

      #
      # /!\ reminder: substitutes only one blob
      #

      i = message.index(' INSERT ') || message.index(' UPDATE ')
      return message unless i

      j = message.index(" x'") || message.index(" X'")
      k = j || message.index(" 0x") || message.index(" 0X")
      return message unless k

      over = j ? [ "'" ] : [ ' ', nil ]

      i = k + 3
      loop do
        c = message[i, 1]
        break if over.include?(c)
        return message unless BLOB_CHARS.index(c)
        i = i + 1
      end

      message[0..k + 2 + 4] + "(...len#{i - (k + 2 + 1)})" + message[i..-1]
    end

    def find_err(elts)

      elts.find { |e| e.is_a?(Exception) } ||
      (defined?(Java) &&
       elts.find { |e| e.class.ancestors.include?(Java::JavaLang::Error) })
    end

    class Out

      attr_reader :unit

      def initialize(unit); @unit = unit; end
      def log_colours?; @unit.conf.fetch('log_colours') { :no } == true; end
      def puts(s); end
      def flush; end
      def close; end

      def self.prepare(unit)

        case o = unit.conf.fetch('log_out', 1)
        when false, 'null' then NoOut.new(unit)
        when 1, true, 'stdout' then StdOut.new(unit, $stdout)
        when 2, 'stderr' then StdOut.new(unit, $stderr)
        when /::/ then Flor.const_lookup(o).new(unit)
        else FileOut.new(unit, o)
        end
      end
    end

    class NoOut < Out

      def log_colours?; false; end
    end

    class StdOut < Out

      def initialize(unit, f); super(unit); @f = f; end
      def log_colours?
        lc = @unit.conf.fetch('log_colours') { :no }
        return lc if [ true, false ].include?(lc)
        @f.tty?
      end
      def <<(s); @f << s; self; end
      def print(s); @f.print(s); end
      def puts(s); @f.puts(s); end
      def flush; @f.flush; end
    end

    class FileOut < Out

      def initialize(unit, dir)

        super(unit)
        @dir = dir

        @mutex = Mutex.new
        @file = nil
        @fname = nil
      end

      def flush; @mutex.synchronize { @file.flush if @file }; end
      def close; @mutex.synchronize { @file.close if @file }; end

      def puts(s)
        @mutex.synchronize { prepare_file.puts(s) }
      end # TODO tstamp!

      protected

      def prepare_file

        fn = File.join(
          @dir, "#{@unit.env}_#{Time.now.strftime('%Y-%m-%d')}.log")

        if fn != @fname
          @file.close if @file
          @file = nil
          @fname = fn
        end

        @file ||= File.open(@fname, 'ab:UTF-8')
      end
    end
  end
end

