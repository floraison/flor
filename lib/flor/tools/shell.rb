
require 'io/console'
require 'terminal-table'

require 'flor'
require 'flor/unit'


module Flor::Tools

  class Shell

    def initialize(argv=nil)

      env = ENV['FLOR_ENV'] || 'shell'
      @root = "envs/#{env}"

      prepare_home

      @unit = Flor::Unit.new("#{@root}/etc/conf.json")

      @unit.conf['unit'] = 'cli'
      #unit.hooker.add('journal', Flor::Journal)

      prepare_db
      prepare_hooks

      @hook = 'on'

      @unit.start

      @flow_path = File.join(@root, 'home/scratch.flo')
      @ra_flow_path = File.join(@root, 'home/ra_scratch.flo')
      @payload_path = File.join(@root, 'home/payload.json')
      @variables_path = File.join(@root, 'home/variables.json')

      @c = Flor.colours({})

      if argv && argv.any?
        do_eval(argv.join(' '))
      else
        print_header
        do_loop
      end
    end

    attr_reader :c

    protected

    def terminal_row_count

      IO.console.winsize[0]
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

    def prepare_db

      @unit.storage.delete_tables if @unit.conf['sto_uri'].match(/memory/)
      @unit.storage.migrate unless @unit.storage.ready?
    end

    def prepare_hooks

      @unit.hook do |message|

        if @hook == 'off'

          # do nothing

        elsif ! message['consumed']

          # do nothing

        elsif %w[ terminated failed ].include?(message['point'])

          sleep 0.4 # let eventual debug print its stuff

          message['payload'] = message.delete('payload')
          message['consumed'] = message.delete('consumed')
            # reorganize to make payload/consumed stand out

          #puts Flor.to_d(message, colour: true, indent: 1, width: true)
          #puts Flor.to_d(message, colour: true)

          c = Flor.colours
          s = StringIO.new
          s << c.dg("\n  /---\n")
          message.each do |k, v|
            s << c.dg << ('  | ') << k << ': ' << v.inspect << c.rs << "\n"
          end
          s << c.dg("  \\---")
          puts s.string
        end
      end
    end

    def print_header

      puts "flosh - a flor #{Flor::VERSION} shell"
    end

    def prompt

      root = @c.dark_gray(@root + '/')

      time = Time.now.strftime(' %H:%M:%S')

      ec = @unit.executions.where(status: 'active').count
      exes = ' ' + @c.yellow("ex#{ec}")

      ti = @unit.timers.where(status: 'active').count
      tis = ti > 0 ? ' ' + @c.yellow("ti#{ti}") : ''

      ta = nil
      if Dir.exist?(File.join(@root, 'var/tasks'))
        ta = Dir[File.join(@root, 'var/tasks/**/*.json')].count
      end
      tas = ta > 0 ? ' ' + @c.yellow("ta#{ta}") : ''

      "#{root}#{time}#{exes}#{tis}#{tas} > "
    end

    def do_eval(line)

      line = line.strip
      return if line[0, 1] == '#'

      md = line.split(/\s/).first
      cmd = "cmd_#{md}".to_sym

      if cmd.size > 4 && methods.include?(cmd)
        begin
          send(cmd, line)
        rescue ArgumentError => aerr
          puts @c.dark_gray(aerr.message)
        rescue StandardError, NotImplementedError => err
          p err
          err.backtrace[0, 7].each { |l| puts "  #{l}" }
        end
      else
        puts "unknown command #{md.inspect}"
      end
    end

    def do_loop

      loop do

        line = prompt_and_read

        break unless line
        next if line.strip == ''

        do_eval(line)
      end

      $stdout.puts
    end

    #
    # command helpers

    ALIASES = {}

    def self.make_alias(a, b)

      define_method("hlp_#{a}") { "alias to #{b.inspect}" }
      alias_method "man_#{a}", "man_#{b}" rescue nil
      alias_method "cmd_#{a}", "cmd_#{b}"

      (ALIASES[b] ||= []) << a
    end

    def self.is_alias?(c)

      !! ALIASES.values.find { |a| a.include?(c) }
    end

    def fname(line, index=1); line.split(/\s+/)[index]; end
    alias arg fname

    def choose_path(line)

      b = arg(line, 2)

      case fname(line)
      when /\Av/,
        @variables_path
      when /\Ap/
        @payload_path
      when /\At/
        fail ArgumentError.new("'frag' argument missing") unless b
        Dir[File.join(@root, 'var/tasks/**/*.json')].find { |pa| pa.index(b) }
      when /\Ar/
        @ra_flow_path
      when /\Ae/
        exe = lookup_execution(b)
#p exe
#pp exe.data
#puts JSON.pretty_generate(exe.data)
#puts JSON.dump(exe.data)
#puts JSON.generate(exe.data, indent: '  ', space: ' ', object_nl: "\n", array_nl: "\n")
puts Flor.to_d(exe.data, width: true, colours: true)
fail NotImplementedError
      else
        @flow_path
      end
    end

    def table_style

      { border_x: "#{@c.dg}-#{@c.rs}",
        border_y: "#{@c.dg}|#{@c.rs}",
        border_i: "#{@c.dg}+#{@c.rs}" }
    end

    def aright(val)

      { value: val, alignment: :right }
    end

    def lookup_exid_nid(line)

      a, b = [ arg(line, 1), arg(line, 2) ]

      fail ArgumentError.new(
        "please specify an exid fragment and a full nid"
      ) unless b

      exid, nid = a.match(/\A[0-9_]+\z/) ? [ b, a ] : [ a, b ]

      onid = nid

      exes = @unit.executions
        .select(:exid, :content)
        .where(Sequel.like(:exid, "%#{exid}%"))
        .where(status: 'active')
        .all

      fail ArgumentError.new(
        "found no execution matching \"%#{exid}%\""
      ) if exes.empty?

      exe = exes
        .find { |e| e.data['nodes'][nid] }

      fail ArgumentError.new(
        "found #{exes.count} execution#{exes.count != 1 ? 's' : ''} " +
        "matching \"%#{exid}%\", but none with a #{onid.inspect} node"
      ) unless exe

      [ exe.exid, nid ]
    end

    def page(type, o)

      fn = "_#{type}.txt"
      s = o.is_a?(String) ? o : o.string

      if s.lines.to_a.size > terminal_row_count
        File.open(fn, 'wb') { |f| f.write(s) }
        system("less -R -N #{fn}")
      else
        puts s
      end
    end

    #
    # the commands

    def hlp_launch
      %{ launches a new execution of #{@flow_path} }
    end
    def man_launch
      %{
        * launch
          launches an execution of the current flow
        * launch k0: v0, k1: v1, ...
          launches an execution with the given variables
      }
    end
    def cmd_launch(line)

      flow = File.read(@flow_path)
      variables = Flor::ConfExecutor.interpret(@variables_path)
      payload = Flor::ConfExecutor.interpret(@payload_path)
      domain = 'shell'

      vars = Flor::ConfExecutor.interpret_line("\n" + line[6..-1]) rescue {}
      variables.merge!(vars)

      exid = @unit.launch(
        flow, domain: domain, vars: variables, payload: payload)

      puts "  launched #{@c.green}#{exid}#{@c.reset}"
    end

    def hlp_help
      %{ displays this help }
    end
    def man_help
      %{
        * help|man
          displays the list of commands and one-line help for each of them
        * help|man cmd
          displays the "manual" for the given command
      }
    end
    def cmd_help(line)

      o = StringIO.new

      if cmd = arg(line)

        begin
          send("man_#{cmd}").split("\n").collect(&:strip).each do |l|
            if l[0, 1] == '*'
              o.puts " #{@c.dg}*#{@c.rs} #{l[1..-1].strip}"
            else
              o.puts "   #{@c.dark_gray(l)}"
            end
          end
        rescue => err
          fail ArgumentError.new("no 'manual' for #{cmd.inspect}")
        end

      else

        o.puts
        o.puts "## available commands:"
        o.puts
        COMMANDS.each do |cmd|
          o.print "* #{@c.yellow(cmd)}"
          if hlp = (send("hlp_#{cmd}") rescue nil)
            o.print " - #{hlp.strip}"
          end
          o.puts
        end
        o.puts
      end

      page(:help, o)
    end
    make_alias('h', 'help')
    make_alias('man', 'help')

    def hlp_exit
      %{ exits this repl, with the given int exit code or 0 }
    end
    def cmd_exit(line)

      exit(line.split(/\s+/)[1].to_i)
    end

    def hlp_parse
      %{ parses #{@flow_path} and displays the resulting tree }
    end
    def man_parse
      %{
        * parse
          parses current #{@flow_path} and render with nids (best)
        * parse d|raw
          parses current #{@flow_path} and render with `.to_djan`
        * parse pp
          parses current #{@flow_path} and render with `pp`
      }
    end
    def cmd_parse(line)

      source = File.read(@flow_path)
      tree = Flor.parse(source, nil, {})

      case arg(line)
      when 'd', 'raw'
        puts Flor.to_d(tree, colours: true, indent: 1, max_width: 80)
      when 'djan'
        puts Flor.to_d(tree, colours: true, indent: 1)
      when 'pp'
        pp tree
      when 'p'
        p tree
      else
        Flor.print_tree(tree, '0', headers: false)
      end
    end

    def hlp_edit
      %{ edit vars, payload, flow or a task }
    end
    def man_edit
      %{
        * edit v|variables
          edits the variables for the next execution
        * edit p|payload
          edits the payload for the next execution
        * edit [f|flow]
          edits the flow for the next execution
        * edit t|task frag
          edits a task currently under var/tasks/
        * edit r
          edits the flow for re-applying
      }
    end
    def cmd_edit(line)

      if path = choose_path(line)
        system("$EDITOR #{path}")
      else
        puts "not found"
      end
    end
    make_alias('e', 'edit')

    def hlp_cat
      %{ prints the current flow }
    end
    def man_cat
      %{
        * cat
          prints the current flow
      }
    end
    def cmd_cat(line)

      puts "  # #{@flow_path}\n"
      File.readlines(@flow_path).each { |line| puts "  #{line}" }
    end

    def hlp_conf
      %{ prints current unit configuration }
    end
    def cmd_conf(line)
      page(
        :configuration,
        Flor.to_d(@unit.conf, colour: true, indent: 1, width: true))
    end

    def hlp_t
      %{ prints the file hierarchy for #{@root} }
    end
    def cmd_t(line)
      puts
      system("tree -C #{@root}")
    end

    def hlp_tasks
      %{ lists the tasks currently under var/tasks/ }
    end
    def man_tasks
      %{
        * tasks
          lists all tasks currently under var/tasks/{tasker}/
        * tasks frag
          lists all tasks whose filename matches the frag
      }
    end
    def cmd_tasks(line)

      o = StringIO.new

      frag = arg(line)

      table = Terminal::Table.new(
        #title: 'tasks',
        headings: %w[ id tasker nid exid payload mtime ],
        style: table_style)

      tas = Dir[File.join(@root, 'var/tasks/**/*.json')]
      tas = tas.select { |pa| pa.index(frag) } if frag

      tas
        .each_with_index { |pa, i|

          ss = pa.split('/')
          tasker = ss[-2]

          exid, nid = Flor.extract_exid_and_nid(ss[-1])

          data = JSON.parse(File.read(pa)) rescue nil
          data = data || { 'payload' => nil }
            #
          pl = Flor.to_d(
            data['payload'],
            colour: false, indent: nil, compact: true)
          pl = @c.dark_gray(pl[0, 21] + '...')

          mt = @c.dark_gray(File.mtime(pa).to_s[0, 19])

          table.add_row([
            aright(i), tasker, nid, @c.yellow(exid), pl, mt ]) }

      o.puts table
      o.puts "#{tas.count} task#{tas.count != 1 ? 's' : ''}.\n"

      page(:tasks, o)
    end
    make_alias('tas', 'tasks')

    def hlp_executions
      %{ lists the executions currently active }
    end
    def man_executions
      %{
        * executions
          lists all the executions currently active
        * executions all
          lists all the executions
      }
    end
    def cmd_executions(line)

      o = StringIO.new

      exes = @unit.executions
      exes = exes.where(status: 'active') unless arg(line) == 'all'

      table = Terminal::Table.new(
        #title: 'executions',
        headings: %w[ id exid name started tis status ],
        style: table_style)
      #table.align_column(0, :right)

      exes
        .each { |e|
          vs = e.zero_variables
          table.add_row([
            aright(e.id),
            @c.yl(e.exid),
            %w[ execution_name process_name flow_name name ]
              .collect { |k| vs[k] }.compact.first,
            e.ctime[0, 19],
            aright(@unit.timers.where(exid: e.exid, status: 'active').count),
            e.failed? ? 'failed' : 'running'
          ]) }

      o.puts table
      o.puts "#{exes.count} execution#{exes.count != 1 ? 's' : ''}.\n"

      page(:executions, o)
    end
    make_alias('exes', 'executions')

    def hlp_timers
      %{ list the timers currently active }
    end
    def cmd_timers(line)

      o = StringIO.new

      tis = @unit.timers
      tis = tis.where(status: 'active') unless arg(line) == 'all'

      table = Terminal::Table.new(
        #title: 'timers',
        headings: [ 'id', 'nid', 'exid', 'type', 'schedule', 'next time' ],
        style: table_style)
      #table.align_column(0, :right)
      #table.align_column(4, :right)

      tis
        .each_with_index { |t, i|
          table.add_row([
            aright(t.id), t.nid, @c.yl(t.exid), t.type,
            aright(t.schedule), t.ntime[0, 19]
          ]) }

      o.puts table
      o.puts "#{tis.count} timer#{tis.count != 1 ? 's' : ''}.\n"

      page(:timers, o)
    end
    make_alias('tis', 'timers')

    def hlp_return
      %{ returns a task to the unit }
    end
    def man_return
      %{
        * return fragment
          given a task filename fragment (for example "ache-0_0")
          reads the task payload and returns it to the unit (making the
          execution go on)
      }
    end
    def cmd_return(line)

      t = arg(line)

      fail ArgumentError.new(
        "please specify a task's exid-nid or a fragment of it"
      ) unless t

      path = Dir[File.join(@root, 'var/tasks/**/*.json')]
        .find { |pa| pa.index(t) }

      fail ArgumentError.new(
        "couldn't find a task matching #{t.inspect}"
      ) unless path

      puts "found task at #{path}"

      m = JSON.parse(File.read(path))
      @unit.return(m)
      FileUtils.rm(path)
    end
    make_alias('ret', 'return')

    def hlp_debug
      %{ re-sets debug flags }
    end
    def man_debug
      %{
        * debug off
          mute unit activity
        * debug on
          verbose unit activity
      }
    end
    def cmd_debug(line)

      @unit.conf.select! { |k, v| ! k.match(/\Alog_/) }

      rest = line.match(/\A[a-z]+(\s+.+)?/)[1]
      rest = nil if rest && rest.strip == 'off'
      rest = 'stdout,dbg' if rest && rest.strip == 'on'

      @unit.conf.merge!(Flor::Conf.interpret_flor_debug(debug: rest)) if rest

      cmd_conf(nil) # display conf
    end

    def hlp_hook
      %{ turns hook for "failed"/"terminated" messages on or off }
    end
    def man_hook
      %{
        * hook on
          hook off, "failed" or "terminated" messages will get printed
          (asynchronously) to console
        * hook off
          messages will not get printed
      }
    end
    def cmd_hook(line)

      @hook =
        case (a = arg(line))
        when 'true', 'on'
          'on'
        when 'false', 'off'
          'off'
        else
          puts "hook is #{@hook.inspect}"
          @hook
        end
    end

    def indent(s, o)

      io = StringIO.new
      o.to_s.split("\n").each do |line|
        io.print(s); io.puts(line)
      end

      io.string
    end

    def h_to_table(h)

      table = Terminal::Table.new(
        headings: %w[ key value ],
        style: table_style)#.merge(all_separators: true))
      h.each do |k, v|
        table.add_row([ k, Flor.to_d(v, colour: true, indent: 0, width: 65) ])
      end

      table
    end

    def lookup_execution(id)

      if id.match(/\A\d+\z/)
        @unit.executions[id.to_i] ||
        fail(ArgumentError.new("execution #{id} not found"))
      else
        @unit.executions.first(Sequel.like(:exid, "%#{id}%")) ||
        fail(ArgumentError.new("execution matching \"%#{id}%\" not found"))
      end
    end

    def detail_execution(id)

      o = StringIO.new

      exe = lookup_execution(id)

      eid = { id: exe.id, exid: exe.exid }.inspect
      con = Flor::Storage.from_blob(exe.values.delete(:content))
      exe.values[:content] = '...'

      o.puts @c.dg("--- exe #{eid} :")
      o.puts h_to_table(exe.values)
      o.puts @c.dg("  exe #{eid} content:")
      nodes = con.delete('nodes')
      con['nodes'] = '...'
      o.puts indent('  ', h_to_table(con))
      o.puts @c.dg("    exe #{eid} content/nodes:")
      table = Terminal::Table.new(
        headings: %w[ nid data ],
        style: table_style.merge(all_separators: true))
      nodes.each do |k, v|
        table.add_row([ k, Flor.to_d(v, colour: true, indent: 0, width: 70) ])
      end
      o.puts indent('    ', table)

      page(:execution, o)
    end

    def detail_timer(id)

      o = StringIO.new

      timer = @unit.timers[id.to_i]

      fail ArgumentError.new("timer #{id} not found") unless timer

      tid = { id: timer.id, exid: timer.exid, nid: timer.nid }.inspect
      timer = timer.values
      con = Flor::Storage.from_blob(timer.delete(:content))
      timer[:content] = '...'

      o.puts @c.dg("--- timer #{tid} :")
      o.puts Flor.to_d(timer, colour: true, indent: 1, width: true)
      o.puts @c.dg("--- timer #{tid} content:")
      o.puts Flor.to_d(con, colour: true, indent: 1, width: true)

      page(:timer, o)
    end

    def detail_task(id)

fail NotImplementedError
    end

    def hlp_detail
      %{ detail an execution, a task or a timer }
    end
    def man_detail
      %{
        * detail e|execution id|frag
          displays full execution information
        * detail ti|timer id
          displays full timer information
        * detail task frag
          displays task
      }
    end
    def cmd_detail(line)

      type, id = arg(line), arg(line, 2)

      fail ArgumentError.new(
        "please specify type (exe, ti, ta) and id (int) or fragment of id"
      ) unless type && id

      case type
      when /\Ae/ then detail_execution(id)
      when /\Ati/ then detail_timer(id)
      when /\At/ then detail_task(id)
      else puts "unknown type #{type.inspect}"
      end
    end
    make_alias('det', 'detail')

    def hlp_cancel
      %{ cancel an execution node }
    end
    def man_cancel
      %{
        * cancel exid_fragment nid
          cancel the first node that matches
        * cancel exid_fragment 0
          cancel the first execution that matches
      }
    end
    def cmd_cancel(line)

      exid, nid = lookup_exid_nid(line)

      @unit.cancel(exid: exid, nid: nid)

      puts @c.yellow("cancel message queued for #{exid} #{nid}")
    end
    make_alias('can', 'cancel')

    def render_node(o, t, nid)

      ni = nid
      head = t[0]
      h = t.last.is_a?(Hash) ? t.last : {}
      if h[:node]
      else
        ni = @c.dark_gray(ni)
        head = @c.dark_gray(head)
      end
      if h[:tasker]
#p h[:tasker]
        rest = @c.green("  <--")
      end

      o.puts "  #{ni} #{head}#{rest}"

      return unless t[1].is_a?(Array)

      t[1].each_with_index do |ct, i|
        render_node(o, t[1][i], "#{nid}_#{i}")
      end
    end

    def hlp_render
      %{ render execution tree with error and tasks locations }
    end
    def man_render
      %{
        * render frag
          finds first execution matching fragment and renders its tree
          highlight current tasks positions
      }
    end
    def cmd_render(line)

      o = StringIO.new

      frag = arg(line)

      exe =
        @unit.executions.first(Sequel.like(:exid, "%#{frag}%")) ||
        fail(ArgumentError.new("execution matching \"%#{frag}%\" not found"))
      o.puts
      o.puts "  exid:    #{@c.yellow(exe.exid)}"
      o.puts "  status:  #{@c.yellow(exe.status)}"
      o.puts

      tree = exe.full_tree
      nodes = exe.nodes

      orphans = []

      nodes.each do |nid, n|
        if st = Flor.tree_locate(tree, nid)
          st << { node: n }
        else
          orphans << n
        end
      end

      @unit.pointers.where(exid: exe.exid, type: 'tasker').each do |pt|
        if st = Flor.tree_locate(tree, pt.nid)
          h = st.last.is_a?(Hash) ? st.last : (st << {})
          h[:tasker] = pt
        else
          orphans << pt
        end
      end

      render_node(o, tree, '0')

      page(:nodes, o)
    end
    make_alias('r', 'render')

    def hlp_reapply
      %{ reapply at a given node with tree ra_sratch.flo }
    end
    def man_reapply
      %{
        * reapply exid_fragment nid
      }
    end
    def cmd_reapply(line)

      exid, nid = lookup_exid_nid(line)

      t = File.read(@ra_flow_path)
      pl = Flor::ConfExecutor.interpret(@payload_path)

      @unit.re_apply(exid: exid, nid: nid, tree: t, payload: pl)

      puts @c.yellow("re-apply message queued for #{exid} #{nid}")
    end

    #
    # enumerate commands (for cmd_help)

    COMMANDS = self.allocate.methods \
      .select { |m| m.to_s.match(/^cmd_/) }.collect { |m| m[4..-1] }.sort

    #
    # use Readline if possible

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

if __FILE__ == $0

  Flor::Tools::Shell.new(ARGV)
end

