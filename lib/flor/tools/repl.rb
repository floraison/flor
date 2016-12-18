
require 'flor'
require 'flor/unit'


module Flor::Tools
  class Repl

    def initialize(env)

      unit = Flor::Unit.new("envs/#{env}/etc/conf.json")

      #pp unit.conf
      unit.conf[:unit] = 'repl'

      #unit.hooker.add('journal', Flor::Journal)
      if unit.conf['sto_uri'].match(/memory/)
        unit.storage.delete_tables
        unit.storage.migrate
      end
      unit.start

      @lines = []
      @payload = {}
      @vars = {}
      @prompt = 'flor> '

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

    protected

    def hlp_launch
      %{ launches the current execution code }
    end
    alias hlp_run hlp_launch

    def cmd_launch(line)

      fail NotImplementedError
    end
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

      _rs, _dg, _yl = Flor.colours({})

      lw = [ 2, lines.size.to_s.length ].max
      sw = 5 - lw

      lines.each_with_index do |l, i|
        puts "#{_dg}% #{sw}s%0#{lw}i #{_yl}%s#{_rs}" % [ '', i + 1, l ]
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

    def cmd_new(line)

      fail NotImplementedError
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
      %{ outputs the content of the give file }
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

    #
    # use Readline if possible

    COMMANDS = self.allocate.methods \
      .select { |m| m.to_s.match(/^cmd_/) }.collect { |m| m[4..-1] }.sort

    begin
      require 'readline'
      def prompt_and_read
        Readline.readline(@prompt, true)
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
        print(@prompt)
        ($stdin.readline rescue false)
      end
    end
  end
end

