
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

    def initialize(unit, msgs)

      @unit = unit
      @storage = unit.storage
      @msgs = msgs

      @execution = nil
    end

    def execute

      exid = @msgs.first['exid']

      @execution =
        @storage.load_execution(exid) ||
        { 'exid' => exid, 'nodes' => {} }

      processed = []

      loop do

        # TODO executor is not threaded, so have to break after
        # a certain number of messages

        msg = @msgs.shift
        break unless msg

        case msg['point']
          when 'execute' then handle_execute(msg)
          when 'receive', 'cancel' then handle_return(msg)
          else handle_event(msg)
        end

        processed.push(msg)
      end

      @storage.flag_as(processed, 'processed')
      @storage.store_back(@msgs)
    end

    protected

    def queue(point, nid, from_nid, h={})

      point = point.to_s
      p = point[0, 1]

      h = h.inject({}) { |hh, (k, v)| hh[k.to_s] = v; hh }
      h['point'] = point
      h['n'] = @execution['msg_counter'] = (@execution['msg_counter'] || 0) + 1
      h['nid'] = nid
      h[point == 'execute' ? 'parent' : 'from'] = from_nid
      h['payload'] = {} if h['payload'].nil? && p == 'e' || p == 'r'

      @msgs << h
    end

    def create_node(msg, nid, parent_nid, tree)

      node = {}
      node['nid'] = nid
      node['ctime'] = Flor.tstamp
      node['parent'] = parent_nid
      node['tree'] = Flor.dup(tree) if nid == '0'

      @execution['nodes'][nid] = node

      node
    end

    def log(msg)

      @unit.logger.log(msg)
    end

    def handle_execute(msg)

      nid = msg['nid'] || '0'
      tree = msg['tree']
      parent_nid = msg['parent']
      payload = msg['payload']

      node = create_node(msg, nid, parent_nid, tree)

      # TODO rewrite tree

      if parent_nid == nil && nid == '0'
        queue(:launched, nid, nil, payload: Flor.dup(payload))
      end

      k = Flor::Ins.const_get(tree.first.capitalize)
      r = k.new(node, msg).execute

      if r == :over
        queue(
          :receive, nid, nid,
          payload: Flor.dup(payload))
      elsif r == :ok
      else # r == :error
        queue(
          :failed, nid, parent_nid,
          payload: Flor.dup(payload), error: node['errors'][-1])
      end

      log(msg)
    end

    def handle_event(msg)

      # TODO

      puts "=== handle_event"
      p msg
      puts "=== handle_event."

      log(msg)
    end

    def handle_return(msg)

      nid = msg['nid'] || '0'
      node = @execution['nodes'][nid]

      return @storage.flag_as([ msg ], 'rejected') unless node

      parent_nid = msg['parent']

      k = Flor::Ins.const_get(tree.first.capitalize)
      n = k.new(node, msg)
      r = msg['point'] == 'receive' ? n.receive : n.cancel

      if r == :over

        parent_nid = Flor.parent_nid(nid)

        if parent_nid

          queue(:receive, parent_nid, nid, payload: Flor.dup(msg['payload']))

        else

          log_delta(node) # log (debug) the age of the execution

          queue(
            nid == '0' ? :terminated : :ceased, nid, nil,
            payload: Flor.dup(msg['payload']))
        end

        @execution['nodes'].delete(nid)

      elsif r == :ok

        # nothing

      else # r == :error

        queue(
          :failed, nid, parent_nid,
          payload: Flor.dup(payload), error: node['errors'][-1])
      end

      log(msg)
    end
  end
end

