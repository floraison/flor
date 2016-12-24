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

  class Executor

    attr_reader :unit
    attr_reader :execution
    attr_reader :traps

    def initialize(unit, traps, execution)

      @unit = unit
      @execution = execution
      @traps = traps
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

    def trigger_hook(hook, message)

      hook.notify(self, message)
    end

    def trigger_trap(trap, message)

      del, msgs = trap.trigger(self, message)
      @traps.delete(trap) if del

      msgs
    end

    protected

    def make_node(message)

      nid = message['nid']

      now = Flor.tstamp

      node = {
        'nid' => nid,
        'parent' => message['from'],
        'payload' => message['payload'],
        'ctime' => now,
        'mtime' => now }

      %w[ vars dvars cnid noreply dbg ].each do |k|
        v = message[k]
        node[k] = v if v != nil
      end
        #
        # vars: variables
        # dvars: domain variables
        # cnid: closure nid
        # noreply: this new node has a parent but shouldn't reply to it
        # dbg: used to debug messages (useful @node['dbg'] when 'receive')

      @execution['nodes'][nid] = node
    end

    def determine_heat(message)

      nid = message['nid']

      return unless nid

      node =
        message['point'] == 'execute' ?
        make_node(message) :
        @execution['nodes'][nid]

      return unless node

      return if node['heat']

      n = Flor::Node.new(self, node, message)

      mt = message['tree']
      mt = [ 'noeval', [ 0 ], mt[2] ] \
        if mt[0] == '_' && Flor.is_array_of_trees?(mt[1])

      nt = n.lookup_tree(nid)

      node['tree'] = mt if mt && (mt != nt)
      tree = node['tree'] || nt

      t0 = tree[0]
      t0 = (t0.is_a?(Array) && t0[0] == '_dqs') ? n.expand(t0[1]) : t0

      node['heat0'] = tree[0]
      node['heat'] = heat = n.deref(t0)

      node['heap'] = heap =
        if ! heat.is_a?(Array)
          '_val'
        elsif tree && tree[1] == []
          '_val'
        elsif heat[0] == '_proc'
          heat[1].is_a?(String) ? heat[1] : heat[1]['_proc']
        elsif heat[0] == '_func'
          'apply'
        elsif heat[0] == '_task'
          'task'
        else
          '_val'
        end

      if heap == 'task' && heat[0] == '_task'
        l = message['tree'][2]
        message['otree'] = Flor.dup(message['tree'])
        message['tree'][0] = 'task'
        message['tree'][1].unshift([ '_att', [ [ '_sqs', heat[1], l ] ], l ])
      end
    end

    def execute(message)

      apply(@execution['nodes'][message['nid']], message)
    end

    def apply(node, message)

      heap =
        if node['heat']
          node['heap']
        else
          node['failure'] ? '_err' : nil
        end

      return error_reply(
        node, message, "don't know how to apply #{node['heat0'].inspect}"
      ) if heap == nil

      heac = Flor::Procedure[heap]
      fail NameError.new("unknown procedure #{heap.inspect}") unless heac

      head = heac.new(self, node, message)

      nid = message['nid']
      pt = message['point']
      pt = 'do_receive' if pt == 'receive'

      if pt == 'execute'
        head.pre_execute
        pnode = @execution['nodes'][node['parent']]
        cnodes = pnode && (pnode['cnodes'] ||= [])
        cnodes << nid if cnodes && ( ! cnodes.include?(nid))
      end
      head.send(pt)
    end

    def remove_node(n)

      return unless n

      n['removed'] = true # or should I use "status" => "removed" ?

      @unit.remove_node(exid, n)
        # remove timers/waiters for this node, if any

      return if (n['closures'] || []).any?
        # don't remove the node if it's a closure for some other nodes

      nid = n['nid']

      return if nid == '0'
        # don't remove if it's the "root" node

      @execution['nodes'].delete(nid)
    end

    def leave(node, message)

      ts = node && node['tags']
      return [] unless ts && ts.any?

      [
        { 'point' => 'left',
          'tags' => ts,
          'exid' => exid,
          'nid' => node['nid'],
          'payload' => message['payload'] }
      ]
    end

    def receive_toc(message, fnode)

      msg =
        %w[
          exid nid from payload
        ].inject({}) { |h, k| h[k] = message[k] if message.has_key?(k); h }

      msg['sm'] = message['m']

      if message['from'] == '0' || @execution['nodes'].empty? # termination?
        msg['point'] = 'terminated'
        msg['vars'] = (fnode || {})['vars']
      else
        msg['point'] = 'ceased'
      end

      [ msg ]
    end

    def receive(message)

      from = message['from']
      fnode = @execution['nodes'][from]

      remove_node(fnode)
      messages = leave(fnode, message)

      nid = message['nid']
      nid = nil if fnode && fnode['noreply']

      return messages + receive_toc(message, fnode) unless nid

      node = @execution['nodes'][nid]

      return messages unless node

      messages + apply(node, message)
    end

    def error_reply(node, message, err)

      # TODO: use node (which may be nil)
#if message['point'] == 'failed'
#  Flor.detail_msg(self, message)
#  #puts "*" * 77
#  #pp message
#  #puts ". . ."
#  #puts caller
#  #puts("*" * 77 + ' .')
#  #exit 1
#end

      m = message
        .select { |k, v| %w[ sm exid nid from payload tree ].include?(k) }

      m['point'] = 'failed'
      m['fpoint'] = message['point']
      m['error'] = Flor.to_error(err)

      Flor.detail_msg(self, m, flag: true) if @unit.conf['log_err']

      [ m ]
    end

    def task(message)

      @unit.tasker.task(message)
    end
    alias detask task

    def return(message)

      [
        { 'point' => 'receive',
          'exid' => message['exid'],
          'nid' => message['nid'],
          'payload' => message['payload'],
          'tasker' => message['tasker'] }
      ]
    end

    def cancel(message)

      if n = @execution['nodes'][message['nid']]
        apply(n, message)
      else
        [] # nothing, node gone
      end
    end

    def process(message)

      begin

        message['m'] = counter_next('msgs') # number messages
        message['pr'] = counter('runs') # "processing run"

        determine_heat(message)

        ms = []
        ms += @unit.notify(self, message) # pre

        ms += self.send(message['point'].to_sym, message)

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

    def entered(message); []; end
    def left(message); []; end

    def terminated(message); []; end
    def ceased(message); []; end

    def failed(message)

#begin
      node(message['nid'])['failure'] = Flor.dup(message)
#rescue; p message; exit 0; end

      oep = lookup_on_error_parent(message)
      return oep.trigger_on_error if oep

      Flor.detail_msg(self, message) if @unit.conf['log_err']

      []
    end

    def signal(message); []; end

    def lookup_on_error_parent(message)

      nd = Flor::Node.new(self, nil, message).on_error_parent
      nd ? nd.to_procedure : nil
    end
  end
end

