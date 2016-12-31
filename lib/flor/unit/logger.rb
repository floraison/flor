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

      @dir = @unit.conf['log_dir'] || 'tmp'
      @dir = '.' unless @dir.is_a?(String) && File.exist?(@dir)

      @fname = nil
      @file = nil

      @mutex = Mutex.new

      @unit.singleton_class.instance_eval do
        define_method(:logger) { @hooker['logger'] }
      end

      @uni = @unit.identifier
    end

    def opts; { consumed: true }; end

    def shutdown

      @file.close if @file
    end

    def debug(*m); log(:debug, *m); end
    def error(*m); log(:error, *m); end
    def info(*m); log(:info, *m); end
    def warn(*m); log(:warn, *m); end

    def log(level, *elts)

      return if [ nil, 'null', false ].include?(@dir)

      n = Time.now.utc
      stp = Flor.nstamp(n)

      out =
        case @dir
          when 'stdout' then $stdout
          when 'stderr' then $stderr
          else prepare_file(n)
        end

      lvl = level.to_s.upcase
      txt = elts.collect(&:to_s).join(' ')
      err = elts.find { |e| e.is_a?(Exception) }

      line = "#{stp} #{@uni} #{lvl} #{txt}"

      @mutex.synchronize do
        if err
          sts = ' ' * stp.length
          lvs = ' ' * (@uni.length + 1 + lvl.length)
          dig = lvl[0, 1] + Digest::MD5.hexdigest(line)[0, 4]
          out.puts("#{stp} #{@uni} #{lvl} #{dig} #{txt}")
          err.backtrace.each { |lin| out.puts("#{sts} #{lvs} #{dig} #{lin}") }
        else
          out.puts(line)
        end
      end
    end

    def notify(executor, msg)

      Flor.print_tree(msg['tree']) \
        if @unit.conf['log_tree'] && msg['point'] == 'execute' && msg['nid'] == '0'

      Flor.log_message(executor, msg) \
        if @unit.conf['log_msg']

      []
    end

    DBCOLS = Flor::Colours.set(%w[ reset bg_light_gray ])
    NO_DBCOLS = [ '' ] * DBCOLS.length

    def db_log(level, msg)

      return unless @unit.conf['log_sto']

      _rs, _co = $stdout.tty? ? DBCOLS : NO_DBCOLS

      #m = msg.match(/ (INSERT|UPDATE) .+ (0?[xX]'?[a-fA-F0-9]+'?)/)
      #msg = msg.sub(m[2], "#{m[2][0, 14]}(...len#{m[2].length})") if m
        #
        # with a fat blob, may lead to memory problems very quickly, hence:
        #
      msg = summarize_blob(msg)

      puts "#{_co}sto#{_rs} t#{Thread.current.object_id} #{level.upcase} #{msg}"
    end

    protected

    def prepare_file(t)

      @mutex.synchronize do

        fn = File.join(
          @dir,
          "#{@unit.conf['env']}_#{t.strftime('%Y-%m-%d')}.log")

        if fn != @fname
          @file.close if @file
          @file = nil
          @fname = fn
        end

        @file ||= File.open(@fname, 'ab')
      end
    end

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
  end
end

