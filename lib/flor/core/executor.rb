
module Flor

  class Executor

    attr_reader :unit
    attr_reader :execution
    attr_reader :hooks
    attr_reader :traps

    def initialize(unit, hooks, traps, execution)

      @unit = unit
      @execution = execution

      @hooks = hooks # raw hooks if any, fresh from the loader
      @traps = traps # array of Trap instances

      @htraps = nil
    end

    def conf; @unit.conf; end
    def exid; @execution['exid']; end

    def node(msg_or_nid, node_instance=false)

      return nil unless msg_or_nid

      nid = msg_or_nid
      msg = msg_or_nid
      #
      if nid.is_a?(String)
        msg = nil
      else
        nid = msg['nid']
      end

      n = @execution['nodes'][nid]

      return nil unless n
      node_instance ? Flor::Node.new(self, n, msg) : n
    end

    def counter(key)

      @execution['counters'][key.to_s] || -1
    end

    def counter_add(key, count)

      k = key.to_s

      @execution['counters'][k] ||= 0
      @execution['counters'][k] += count
    end

    def counter_next(key)

      counter_add(key, 1)
    end

    def trigger_trap(trap, message)

      del, msgs = trap.trigger(self, message)
      @traps.delete(trap) if del

      msgs
    end

    def trigger_hook(hook, message)

      m =
        case
        when hook.respond_to?(:notify) then :notify
        when hook.respond_to?(:on_message) then :on_message
        else :on
        end
      as =
        case hook.method(m).arity
        when 3 then [ @unit, self, message ]
        when 2 then [ self, message ]
        else [ message ]
        end

      r = hook.send(m, *as)

      Flor.is_array_of_messages?(r) ? r : []
    end

    def trigger_block(block, opts, message)

      r =
        case block.arity
        when 1 then block.call(message)
        when 2 then block.call(message, opts)
        else block.call(self, message, opts)
        end

      r.is_a?(Array) && r.all? { |e| e.is_a?(Hash) } ? r : []
        # be lenient with block hooks, help them return an array
    end

    # Given a nid, returns a copy of all the var the node sees at that point.
    #
    def vars(nid, vs={})

      n = node(nid); return vs unless n

      (n['vars'] || {})
        .each { |k, v| vs[k] = Flor.dup(v) unless vs.has_key?(k) }

      pnid = n['parent']

      if @unit.loader && pnid == nil && n['vdomain'] != false

        @unit.loader.variables(n['vdomain'] || Flor.domain(@exid))
          .each { |k, v| vs[k] = Flor.dup(v) unless vs.has_key?(k) }
      end

      if cn = n['cnid']; vars(cn, vs); end
      vars(pnid, vs) if pnid

      vs
    end

    def traps_and_hooks

      @htraps = nil if @htraps && @htraps.size != @traps.size

      @htraps ||= @traps.collect(&:to_hook)
      @hhooks ||= @hooks.collect(&:to_hook)

      @htraps + @hhooks
    end

    protected

    def make_node(message)

      nid = message['nid']

      n = Flor.tstamp

      node = {
        'nid' => nid,
        'parent' => message['from'],
        'payload' => message['payload'],
        'status' => [ { 'status' => nil, 'point' => 'execute', 'ctime' => n } ],
        'ctime' => n,
        'mtime' => n }

      %w[ vars vdomain cnid dbg ].each do |k|
        v = message[k]
        node[k] = v if v != nil
      end
        #
        # vars: variables
        # vdomain: variable domain (used in conjuction with the loader)
        # cnid: closure nid
        # dbg: used to debug messages (useful @node['dbg'] when 'receive')

      %w[ error cancel timeout ]
        .each { |k|
          h = message["on_#{k}_handler"]
          node["on_#{k}"] = [ h ] if h }

      @execution['nodes'][nid] = node
    end

    def determine_heat(message)

      nid = message['nid']

      return unless nid

      node =
        message['point'] == 'execute' ?
        make_node(message) :
        @execution['nodes'][nid]

      return if node.nil? || node['heat']

      n = Flor::Node.new(self, node, message)

      mt = message['tree']
      mt = [ 'noeval', [ 0 ], mt[2] ] \
        if mt[0] == '_' && Flor.is_array_of_trees?(mt[1])

      nt = n.lookup_tree(nid)

      node['tree'] = mt if mt && (mt != nt)
      tree = node['tree'] || nt

      node['heat0'] = t0 = tree[0]
      node['heat'] = heat = n.deref(t0)

      if heat == nil && ! message['accept_symbol']

        node['heat'] = '(none)'

        fail FlorError.new("cannot find #{t0.inspect}", n) if tree[1].empty?
        fail FlorError.new("don't know how to apply #{t0.inspect}", n)
# TODO how about _ref and letting that procedure fail
      end

      node['heap'] = heap = n.reheap(tree, heat)

      # "exceptions"

      if heat == nil #&& message['accept_symbol']
        #
        # tag: et al

        node['tree'] = message['tree'] = t = [ '_sqs', tree[0], tree[2] ]

        node['heat0'] = t[0]
        node['heat'] = h = n.deref(t[0])
        node['heap'] = n.reheap(t, h)

      elsif heap == 'task' && heat[0] == '_tasker'
        #
        # rewrite `alpha` into `task alpha`

        l = message['tree'][2]

        message['otree'] = Flor.dup(message['tree'])

        message['tree'][0] =
          'task'
        message['tree'][1].unshift(
          [ '_att', [ [ '_sqs', heat[1]['tasker'], l ] ], l ])
      end
    end

    def execute(message)

      apply(@execution['nodes'][message['nid']], message)
    end

    def apply(node, message)

      heap = node['heap']

      heac = Flor::Procedure[heap]
unless heac
  puts "v" * 80
  puts "===node:"
  p node['nid']
  p heap
  puts "."
  pp node
  puts "===message:"
  p message['point']
  puts "."
  pp message
  puts "." * 80
end
      fail NameError.new("unknown procedure #{heap.inspect}") unless heac

      head = heac.new(self, node, message)

      return [ head.rewrite ] if head.is_a?(Flor::Macro)

      point = message['point']
      point = 'kill' if message['flavour'] == 'kill'

      messages = head.send("do_#{point}")

      fail StandardError.new(
        "#{heap}/#{message['point']} did not return an Array"
      ) unless messages.is_a?(Array)

      messages
    end

    def toc_messages(message)

      return [] if message['flavour'] == 'flank'

      m = message.select { |k, v| %w[ exid nid from payload ].include?(k) }
      m['sm'] = message['m']
      m['point'] = message['from'] == '0' ? 'terminated' : 'ceased'
      m['cause'] = message['cause'] if message.has_key?('cause')

      [ m ]
    end

    def receive(message)

      messages = leave_node(message)

      nid = message['nid']

      return messages + toc_messages(message) unless nid
        # 'terminated' or 'ceased'

      node = @execution['nodes'][nid]

      return messages unless node
        # node gone...

      messages + apply(node, message)
    end

    def leave_node(message)

      return [] if %w[ flank part ].include?(message['flavour'])

      fnid = message['from']; return [] unless fnid
      fnode = @execution['nodes'][fnid]; return [] unless fnode

      remove_node(message, fnode) +
      leave_tags(message, fnode)
    end

    def remove_node(message, node)

      nid = node['nid']
      cls = node['closures']

      pro = Flor::Procedure.make(self, node, message)
      pro.end

      cancels = pro.send(:wrap_cancel_children, 'cancel_trailing' => true)

      return cancels if cls && cls.any?
        # don't remove the node if it's a closure for some other nodes

      return cancels if nid == '0'
        # don't remove if it's the "root" node

      @unit.archive_node(message['exid'], node)
        # archiving is only active during testing

      #update_parent_node_tree(node)

      @execution['nodes'].delete(nid)

      cancels
    end

  # This saves the modified trees in the parent when the node is removed
  # it works ok except for 3 (2017-05-9) failing specs.
  #
  # Introducing 3 exceptions for this is not interesting.
  #
#    def update_parent_node_tree(node)
#
#      t = node['tree']; return unless t
##return if t[0] == '_apply'
#      pnode = @execution['nodes'][node['parent']]; return unless pnode
#
#      pt =
#        pnode['tree'] ||
#        Flor::Node.new(self, pnode, nil).lookup_tree(pnode['nid'])
#      cid =
#        Flor.child_id(node['nid'])
#
#      if cid == pt[1].size # head "exception"
#        return if pt[0] == t
#        pt[0] = t
#        pnode['tree'] = pt
#        return
#      end
#
#      pt[1][cid] = t
#      pnode['tree'] = pt
#    end

    def leave_tags(message, node)

      ts = node['tags']; return [] unless ts && ts.any?

      [ { 'point' => 'left',
          'tags' => ts,
          'exid' => exid,
          'nid' => node['nid'],
          'payload' => message['payload'] } ]
    end

    def error_reply(node, message, err)

      m = Flor.to_error_message(message, err)

      @unit.logger.log_err(self, m, flag: true)

      #if m['error']['msg'].match(/\AToo many open files in system/)
      #  puts "=" * 80 + ' ...'
      #  system(`lsof #{Process.pid}`)
      #  puts "=" * 80 + ' .'
      #end
        #
        # can't seem to provoke that error, so keeping the trap
        # around but commented out...

      [ m ]
    end

    def cancel(message)

      n = @execution['nodes'][message['nid']]
      return [] unless n # node gone

      apply(n, message)
    end

    def stack_cause(message)

      pt = message['point']
      fl = message['flavour']

      cause = pt # trigger or cancel
      cause = fl if %w[ kill timeout ].include?(fl) # only for cancel, hopefully

      last = (message['cause'] ||= [])[0]

      c = { 'cause' => cause, 'at' => last && last['at'] }
      %w[ m sm nid type ].each { |k| c[k] = message[k] }

      return if c == last

      # argh, the causes in the messages go most recent first
      # while the statuses in the nodes go most recent last

      message['cause'] =
        [ c.tap { |h| h['at'] = Flor.tstamp } ] +
        message['cause']
    end

    def process(message)

p message if ENV['FLOR_DEBUG__']
      fail ArgumentError.new("incoming message has non nil or Hash payload") \
        unless message['payload'] == nil || message['payload'].is_a?(Hash)
          #
          # weed out messages with non-conforming payloads

      begin

        message['m'] = counter_next('msgs') # number messages
        message['pr'] = counter('runs') # "processing run"

        stack_cause(message) \
          if %w[ trigger cancel ].include?(message['point'])

        begin
          determine_heat(message)
        rescue => e
          raise e unless message['point'] == 'failed'
        end

        ms = []
        ms += @unit.notify(self, message) # pre

        ms += send(message['point'], message)

        message['payload'] = message.delete('pld') if message.has_key?('pld')
        message['consumed'] = Flor.tstamp

        ms += @unit.notify(self, message) # post

        ms.each { |m| m['er'] = counter('runs') } # "emitting run"

      rescue => e
        error_reply(nil, message, e)
      rescue ScriptError => se
        error_reply(nil, message, se)
      end
    end

    def trap(message)

      exid = message['exid']
      nid = message['nid']
      trap = message['trap']

      nd = node(nid)
      nd['exid'] = exid

      @traps << @unit.trap(nd, trap)

      []
    end

    def terminated(message)

      message['vars'] = @execution['nodes']['0']['vars']
        # especially useful for debugging

      []
    end

    def failed(message)

      n = node(message['nid'])

      fail RuntimeError.new(
        "node #{message['nid']} is gone, cannot flag it as failed"
      ) unless n

      n['failure'] = Flor.dup(message)

      if oep = lookup_on_error_parent(message)
        #
        # There is a parent with an 'on_error', trigger it that parent
        # with its 'on_error' turned on.
        #
        oep.trigger_on_error
        #
      else
        #
        # Simply log and don't add further messages ([]) to execute
        #
        @unit.logger.log_err(self, message)
        []
      end
    end

    def signal(message); []; end
    def entered(message); []; end
    def left(message); []; end
    def ceased(message); []; end
      #
      # Return an empty array of new messages. No direct effect.
      #
      # Some trap, hook, and/or waiter might lie in wait though.

    def lookup_on_error_parent(message)

      nd = Flor::Node.new(self, nil, message).on_error_parent
      nd ? nd.to_procedure_node : nil
    end
  end
end

