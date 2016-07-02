#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
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
    end

    def shutdown
    end

    def debug(*m); log(:debug, *m); end
    def error(*m); log(:error, *m); end
    def info(*m); log(:info, *m); end
    def warn(*m); log(:warn, *m); end

    def notify(executor, message)

      if message['point'] == 'execute' && message['nid'] == '0'
        Flor.print_tree(message['tree']) if @unit.conf['log_tree']
      end

      Flor.log_message(executor, message) if @unit.conf['log_msg']
    end

    DBCOLS = Flor::Colours.set(%w[ reset bg_light_gray ])
    NO_DBCOLS = [ '' ] * DBCOLS.length

    def db_log(level, msg)

      return unless @unit.conf['log_sto']

      _rs, _co = $stdout.tty? ? DBCOLS : NO_DBCOLS

      m = msg.match(/ (INSERT|UPDATE) .+ (0?[xX]'?[a-fA-F0-9]+'?)/)
      msg = msg.sub(m[2], "#{m[2][0, 14]}(...len#{m[2].length})") if m
        # reminder: substitutes only one blob

      puts "#{_co}sto#{_rs} t#{Thread.current.hash} #{level.upcase} #{msg}"
    end
  end
end

