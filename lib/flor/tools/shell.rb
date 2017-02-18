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

require 'awesome_print' rescue nil

require 'flor'
require 'flor/unit'


module Flor::Tools

  class Shell

    def initialize

      env = ENV['FLOR_ENV'] || 'shell'
      @root = "envs/#{env}"

      prepare_home

      @unit = Flor::Unit.new("#{@root}/etc/conf.json")

      @unit.conf['unit'] = 'cli'

      #unit.hooker.add('journal', Flor::Journal)

      if @unit.conf['sto_uri'].match(/memory/)
        @unit.storage.delete_tables
        @unit.storage.migrate
      end
      @unit.start

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
      @flow_path = File.join(@root, 'home/scratch.flo')
      @payload_path = File.join(@root, 'home/payload.json')
      @variables_path = File.join(@root, 'home/variables.json')

      @c = Flor.colours({})

      do_loop
    end

    attr_reader :c

    protected

    # nice print
    def np(o)
      defined?(AwesomePrint) ? ap(o) : pp(o)
    end

    def prepare_home

      home = File.join(@root, 'home')
      return unless Dir.exists?(home)

      %w[ payload.json scratch.flo variables.json ].each do |fn|

        hfn = File.join(home, fn); next if File.exists?(hfn)

        FileUtils.cp(hfn + '.template', hfn)
        puts ".. prepared #{hfn}"
      end
    end

    def prompt

      tasks = Dir[File.join(@root, 'var/tasks/**/*.json')]

      "flor #{@c.blue}#{tasks.count}#{@c.reset} > "
    end

    def do_loop

      loop do

        line = prompt_and_read

        break unless line
        next if line.strip == ''

        md = line.split(/\s/).first
        cmd = "cmd_#{md}".to_sym

        if cmd.size > 4 && methods.include?(cmd)
          begin
            send(cmd, line)
          rescue StandardError, NotImplementedError => err
            p err
            err.backtrace[0, 7].each { |l| puts "  #{l}" }
          end
        else
          puts "unknown command #{md.inspect}"
        end
      end

      $stdout.puts
    end

    def hlp_launch
      %{ launches a new execution of #{@flow_path} }
    end
    def cmd_launch(line)

      flow = File.read(@flow_path)
      variables = Flor::ConfExecutor.interpret(@variables_path)
      payload = Flor::ConfExecutor.interpret(@payload_path)
      domain = 'shell'

      exid = @unit.launch(
        flow, domain: domain, vars: variables, payload: payload)

      puts "  launched #{@c.green}#{exid}#{@c.reset}"
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
        print "* #{@c.yellow}#{cmd}#{@c.reset}"
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

    def hlp_parse
      %{ parses #{@flow_path} and displays the resulting tree }
    end
    def cmd_parse(line)

      source = File.read(@flow_path)
      tree = Flor::Lang.parse(source, nil, {})

      case arg(line)
      when 'raw' then np tree
      when 'pp' then pp tree
      when 'p' then p tree
      else Flor.print_tree(tree, '0', headers: false)
      end
    end

    def fname(line); line.split(/\s+/)[1]; end
    alias arg fname

    def choose_path(line)

      path =
        case fname(line)
        when /\Av/ then @variables_path
        when /\Ap/ then @payload_path
        else @flow_path
        end
    end

    def hlp_cat
      %{ outputs the content of the given file }
    end
    def cmd_cat(line)

      puts File.read(choose_path(line))
    end

    def hlp_edit
      %{ open current file for edition }
    end
    def cmd_edit(line)

      system("$EDITOR #{choose_path(line)}")
    end

    def hlp_conf
      %{ prints current unit configuration }
    end
    def cmd_conf(line)
      np @unit.conf
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

