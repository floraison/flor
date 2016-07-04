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
    include Flor::Ash

    attr_reader :execution
    attr_reader :unit

    def initialize(unit, traps, execution)

      @unit = unit
      @traps = traps
      @execution = execution
    end

    def conf; @unit.conf; end

    def exid; @execution['exid']; end

    def counter_next(key)

      k = key.to_s

      @execution['counters'][k] ||= 0
      @execution['counters'][k] += 1
    end

    protected

    def execute(message)

      nid = message['nid']

      now = Flor.tstamp

      node = {
        'nid' => nid,
        'parent' => message['from'],
        'payload' => ash(message, 'payload'),
        'ctime' => now,
        'mtime' => now }

      if vs = message['vars']
        node['vars'] = vs
      end
      if cnid = message['cnid']
        node['cnid'] = cnid
      end

      @execution['nodes'][nid] = node

      apply(node, message)
    end

    def apply(node, message)

      n = Flor::Node.new(self, node, message)

      mt = message['tree']
      nt = n.lookup_tree(node['nid'])
      node['tree'] = mt if mt && (mt != nt)
      tree = node['tree'] || nt

      t0 = tree[0]
      t0 = (t0.is_a?(Array) && t0[0] == '_dqs') ? n.expand(t0[1]) : t0

      heat = n.deref(t0)

      return error_reply(
        node, message, "don't know how to apply #{tree[0].inspect}"
      ) if heat == nil

      heak =
        if ! heat.is_a?(Array)
          Flor::Pro::Val
        elsif tree[1] == []
          Flor::Pro::Val
        elsif heat[0] == '_proc'
          Flor::Procedure[heat[1]]
        elsif heat[0] == '_func'
          Flor::Pro::Apply
        else
          Flor::Pro::Val
        end

      head = heak.new(self, node, message)
      head.heat = heat if head.respond_to?(:heat=)

      head.pre_execute if message['point'] == 'execute'

      head.send(message['point'])
    end

    def remove_node(n)

      return unless n

      n['deleted'] = true # or should I use "status" => "deleted" ?

      @unit.remove_node(exid, n)
        # remove timers/waiters for this node, if any

      return if (n['closures'] || []).any?
        # don't remove the node if it's a closure for some other nodes

      @execution['nodes'].delete(n['nid'])
    end

    def leave(node, message)

      ts = node && node['tags']
      return [] unless ts

      [
        { 'point' => 'left',
          'tags' => ts,
          'exid' => exid,
          'nid' => node['nid'],
          'payload' => message['payload'] }
      ]
    end

    def receive(message)

      from = message['from']
      fnode = @execution['nodes'][from]

      remove_node(fnode)
      messages = leave(fnode, message)

      nid = message['nid']

      return messages + [
        message.merge('point' => 'terminated', 'vars' => (fnode || {})['vars'])
      ] unless nid

      node = @execution['nodes'][nid]

      #return messages + [
      #  message.merge('point' => 'ceased', 'nid' => from, 'from' => nil)
      #] unless node
      return messages unless node

      messages + apply(node, message)
    end

    def error_reply(node, message, err)

      # TODO: use node (which may be nil)

      m = { 'point' => 'failed' }
      m['fpoint'] = message['point']
      m['exid'] = message['exid']
      m['nid'] = message['nid']
      m['from'] = message['from']
      m['payload'] = message['payload']
      m['tree'] = message['tree']
      m['error'] = Flor.to_error(err)

      [ m ]
    end

    def task(message)

      @unit.tasker.task(unash_all!(message, true))
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

    def process(message)

      begin

        ash_all!(message)

        @unit.notify(self, message) # pre

        ms = self.send(message['point'].to_sym, message)
        message['consumed'] = Flor.tstamp

        ms += notify_traps(message)

        @unit.notify(self, message) # post

        ms.collect { |m| ash_all!(m) }

      rescue => e
        error_reply(nil, message, e)
      rescue ScriptError => se
        error_reply(nil, message, se)
      end
    end

    def notify_traps(message)

      to_remove = []
      messages = []

      @traps.each do |t|
        remove, messages = t.notify(self, message)
        to_remove << t if remove
      end

      @traps -= to_remove

      messages
    end

    def trap(message)

      exid = message['exid']
      nid = message['nid']
      trap = message['trap']

      node = @execution['nodes'][message['nid']]
      node['exid'] = exid

      msg = {
        'point' => 'execute',
        'exid' => exid, 'nid' => trap['nid'],
        'tree' => trap['tree']
      }

      @traps << @unit.trap(node, trap, msg)

      []
    end

    def entered(message); []; end
    def left(message); []; end
  end
end

