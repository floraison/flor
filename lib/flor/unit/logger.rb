#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

module Flor

  class Logger

    # NB: logger configuration entries start with "log_"

    def initialize(unit)

      @unit = unit

      @out = prepare_out

      @uni = @unit.identifier
    end

    def opts; { consumed: true }; end

    def shutdown

      #@file.close if @file
      @out.close
    end

    def debug(*m); log(:debug, *m); end
    def error(*m); log(:error, *m); end
    def info(*m); log(:info, *m); end
    def warn(*m); log(:warn, *m); end

    def log(level, *elts)

      n = Time.now.utc
      stp = Flor.tstamp(n)

      lvl = level.to_s.upcase
      txt = elts.collect(&:to_s).join(' ')
      err = elts.find { |e| e.is_a?(Exception) }

      line = "#{stp} #{@uni} #{lvl} #{txt}"

      if err
        sts = ' ' * stp.length
        lvs = ' ' * (@uni.length + 1 + lvl.length)
        dig = lvl[0, 1] + Digest::MD5.hexdigest(line)[0, 4]
        @out.puts("#{stp} #{@uni} #{lvl} #{dig} #{txt}")
        err.backtrace.each { |lin| @out.puts("  #{dig} #{@uni} #{lin}") }
      else
        @out.puts(line)
      end
    end

    def notify(executor, msg)

# TODO log to outfile
      if msg['rewritten'] && @unit.conf['log_tree_rw']

        Flor.print_compact_tree(
          msg['rewritten'], msg['nid'],
          ind: 6, title: "rewrote #{msg['exid']} #{msg['nid']}",
          out: @out)
        Flor.print_compact_tree(
          msg['tree'], msg['nid'],
          ind: 6, title: "into #{msg['exid']} #{msg['nid']}",
          close: true,
          out: @out)
      end

      if @unit.conf['log_msg']

        Flor.log_message(executor, msg, out: @out)
      end

      [] # we're only logging, do not queue further messages
    end

    def db_log(level, msg)

      return unless @unit.conf['log_sto']

      _c = Flor.colours(out: @out)

      #m = msg.match(/ (INSERT|UPDATE) .+ (0?[xX]'?[a-fA-F0-9]+'?)/)
      #msg = msg.sub(m[2], "#{m[2][0, 14]}(...len#{m[2].length})") if m
        #
        # with a fat blob, may lead to memory problems very quickly, hence:
        #
      msg = summarize_blob(msg)

      @out.puts "#{_c.blg}sto#{_c.rs} t#{Thread.current.object_id} #{level.upcase} #{msg}"
    end

    def log_run_start(executor)

      return unless @unit.conf['log_run']

      execution = executor.execution
      _c = Flor.colours(out: @out)
      s = StringIO.new

      s << _c.dg
      s << "    /--- #{_c.lg}run starts#{_c.dg} "
      s << "#{executor.class} #{executor.object_id} #{execution['exid']}"
      s << "\n    |   "
      s << { thread: Thread.current.object_id }.inspect
      s << "\n    |   "
      s << {
        counters: execution['counters'],
        nodes: execution['nodes'].size,
        size: execution['size']
      }.inspect
      s << _c.rs

      @out.puts(s.string)
    end

    def log_run_end(executor, t0)

      return unless @unit.conf['log_run']

      execution = executor.execution
      _c = Flor.colours(out: @out)
      s = StringIO.new

      s << _c.dg
      s << "    |   run ends #{self.class} #{self.object_id} #{@exid}"
      s << "\n    |   "; s << { took: Time.now - t0 }.inspect
      s << "\n    |   "; s << {
        thread: Thread.current.object_id,
        consumed: executor.consumed.count,
        traps: executor.traps.count,
      }.inspect
      s << "\n    |   "; s << {
        #own_traps: @traps.reject { |t| t.texid == nil }.size, # FIXME
        counters: execution['counters'],
        nodes: execution['nodes'].size,
        size: execution['size']
      }.inspect
      if @unit.archive
        s << "\n    |   "
        s << {
          archive_size: @unit.archive[@exid].size
        }.inspect
      end
      s << "\n    \\--- ."
      s << _c.rs

      @out.puts(s.string)
    end

    def log_err(executor, message, opts={})

      return unless @unit.conf['log_err']

      Flor.print_detail_msg(executor, message, opts.merge(out: @out))
    end

    def log_src(source, opts, log_opts={})

      return unless @unit.conf['log_src']

      Flor.print_src(source, opts, log_opts.merge(out: @out))
    end

    def log_tree(tree, nid='0', opts={})

      return unless @unit.conf['log_tree']

      Flor.print_tree(tree, nid, opts.merge(out: @out))
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

    def prepare_out

      case (o = @unit.conf['log_out'] || 'stdout')
        when false, 'null' then NoOut.new(@unit)
        when true, 'stdout' then StdOut.new(@unit, $stdout)
        when 'stderr' then StdOut.new(@unit, $stderr)
        when /::/ then Flor.const_lookup(o).new(@unit)
        else FileOut.new(@unit, o)
      end
    end

    class Out
      attr_reader :unit
      def initialize(unit); @unit = unit; end
      def log_colours?; @unit.conf.fetch('log_colours') { :no } == true; end
      def puts(s); end
      def flush; end
      def close; end
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

        @file ||= File.open(@fname, 'ab')
      end
    end
  end
end

