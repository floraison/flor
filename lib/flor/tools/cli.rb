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

require 'flor'
require 'flor/unit'


module Flor::Tools

  class Cli

    def initialize

      env = ENV['FLOR_ENV'] || 'cli'

      @unit = Flor::Unit.new("envs/#{env}/etc/conf.json")

      #pp @unit.conf
      @unit.conf[:unit] = 'cli'

      #unit.hooker.add('journal', Flor::Journal)
      if @unit.conf['sto_uri'].match(/memory/)
        @unit.storage.delete_tables
        @unit.storage.migrate
      end
      @unit.start

#      @lines = []
#      @payload = {}
#      @vars = {}
#
#      @outcome = nil
#
#      @unit.hook do |message|
#
#        if ! message['consumed']
#          # do nothing
#        elsif %w[ terminated failed ].include?(message['point'])
#          @outcome = message
#          out = Flor.to_pretty_s(@outcome)
#          col = message['point'] == 'failed' ? c.rd : c.gr
#          out = out.gsub(/"point"=>"([^"]+)"/, "\"point\"=>\"#{col}\\1#{c.y}\"")
#          out = "\n" + c.yl + out + c.rs
#          out = out.split("\n").collect { |l| '  ' + l }.join("\n")
#          print(out)
#        end
#      end

      @c = Flor.colours({})

      do_loop
    end

    attr_reader :c

    protected

    def prompt

      "flor l#{@lines.size} > "
    end

    def do_loop

      loop do

        line = prompt_and_read

        break unless line
        next if line.strip == ''

        cmd = "cmd_#{line.split(/\s/).first}".to_sym

        if cmd.size > 4 && methods.include?(cmd)
          begin
            send(cmd, line)
          rescue StandardError, NotImplementedError => err
            p err
            err.backtrace[0, 7].each { |l| puts "  #{l}" }
          end
        else
          @lines << line
        end
      end

      $stdout.puts
    end

    def hlp_launch
      %{ launches the current execution code }
    end
    def cmd_launch(line)

      exid = @unit.launch(@lines.join("\n"), vars: @vars, payload: @payload)
      puts "  launched #{c.yl}#{exid}#{c.rs}"
    end

    alias hlp_run hlp_launch
    alias cmd_run cmd_launch

    def hlp_help
      %{ displays this help }
    end
    def cmd_help(line)

      puts
      puts "## available commands:"
      puts
      COMMANDS.each do |cmd|
        print "* #{cmd}"
        if hlp = (send("hlp_#{cmd}") rescue nil); print " - #{hlp.strip}"; end
        puts
      end
      puts
    end

    def hlp_exit
      %{ exits this repl, with the given int exit code or 0 }
    end
    def cmd_exit(line)

      exit(line.split(/\s+/)[1].to_i)
    end

    def hlp_list
      %{ lists the lines of the current execution code }
    end
    def do_list(lines)

      lw = [ 2, lines.size.to_s.length ].max
      sw = 5 - lw

      lines.each_with_index do |l, i|
        puts "#{c.dg}% #{sw}s%0#{lw}i #{c.yl}%s#{c.rs}" % [ '', i + 1, l ]
      end
    end
    def cmd_list(line)

      do_list(@lines)
    end

    def hlp_parse
      %{ parses the current execution code and displays its tree }
    end
    def cmd_parse(line)

      Flor.print_tree(
        Flor::Lang.parse(@lines.join("\n"), nil, {}),
        '0',
        headers: false)
    end

    def hlp_new
      %{ erases current execution code, vars and payload }
    end
    def cmd_new(line)

      @lines = []
      @vars = {}
      @payload = {}
    end

    def fname(line)

      line.split(/\s+/)[1]
    end

    def hlp_save
      %{ saves the current execution code to the given file }
    end
    def cmd_save(line)

      File.open(fname(line), 'wb') { |f| f.puts @lines }
    end

    def hlp_cat
      %{ outputs the content of the given file }
    end
    def cmd_cat(line)

      do_list(File.readlines(fname(line)).collect(&:chomp))
    end

    def hlp_load
      %{ loads a file as execution code }
    end
    def cmd_load(line)

      @lines = File.readlines(fname(line)).collect(&:chomp)
    end

    def cmd_cont(line)

      fail NotImplementedError
    end

    def hlp_edit
      %{ saves the current execution code to .tmp.flo and opens it for edition }
    end
    def cmd_edit(line)

      cmd_save('save .tmp.flo')
      system('$EDITOR .tmp.flo')
      cmd_load('load .tmp.flo')
      FileUtils.rm('.tmp.flo')
    end

    #
    # use Readline if possible

    COMMANDS = self.allocate.methods \
      .select { |m| m.to_s.match(/^cmd_/) }.collect { |m| m[4..-1] }.sort

    begin
      require 'readline'
      def prompt_and_read
        Readline.readline(prompt, true)
      end
      Readline.completion_proc =
        proc { |s|
          r = /^#{Regexp.escape(s)}/
          COMMANDS.grep(r) + Dir["#{s}*"].grep(r)
        }
      #Readline.completion_append_character =
      #  " "
    rescue LoadError => le
      def prompt_and_read
        print(prompt)
        ($stdin.readline rescue false)
      end
    end
  end
end

