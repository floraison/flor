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

  class Trap < FlorModel

    # returns [ remove?, [ messages ] ]
    #
    def notify(executor, message)

      if match?(executor, message)
        [ decrement, [ to_trigger_message(executor, message) ] ]
      else
        [ false, [] ]
      end

      # false => remove? false
    end

    protected

    # returns true if the trap should be removed from the execution's list
    # of traps
    #
    def decrement

      c = data['count']
      return false unless c

      c = c - 1
      data['count'] = c
      self[:status] = c > 0 ? 'active' : 'consumed'

      self.update(content: Flor::Storage.to_blob(@data), status: self[:status])

      c < 1
    end

    def to_trigger_message(executor, message)

      msg = self.data(false)['message']

      msg['trap_id'] = self.id

      if vs = msg['vars']
        k = vs.keys.find { |k| k != 'arguments' }
        vs[k] = message
      end

      #xx = executor.counter_next('xx')
      #msg['dbg'] = xx

      {
        'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.nid,
        'type' => 'trap',
        'trap' => to_hash,
        'trap_id' => self.id,
        'message' => msg,
        #'dbg' => xx
      }#.tap { |m| p m }
    end

    def to_hash

      values.inject({}) { |h, (k, v)| h[k.to_s ] = v if k != :content; h }
    end

    def match?(executor, message)

      return false if message['point'] == 'trigger' #&& message['trap_id']

      return false if tconsumed && ! message['consumed']
      return false if ! tconsumed && message['consumed']

      return false if in_trap_itself?(executor, message)

      return false unless point_match?(message)
      return false unless tag_match?(message)

      return false unless domain_match?(executor, message)

      return false unless heap_match?(executor, message)
      return false unless heat_match?(executor, message)

      true
    end

    def domain_match?(executor, message)

      return true \
        if trange == 'subdomain'

      return Flor.domain(message['exid']) == domain \
        if trange == 'domain'

      return false \
        unless message['exid'] == exid

      return true \
        if trange == 'execution'

      nid_match?(executor, message)
    end

    def nid_match?(executor, message)

      n = executor.node(message['nid'], true)

      return nid == '0' unless n
      n.descendant_of?(nid, true)
    end

    def in_trap_itself?(executor, message)

      return false if message['exid'] != exid

      n = executor.node(message['from'] || message['nid'], true)
      return false if n == nil

      n.descendant_of?(onid)
    end

    def point_match?(message)

      tpoints.empty? ||
      tpoints.include?(message['point'])
    end

    def tag_match?(message)

      ttags.empty? ||
      ttags.find { |t| (message['tags'] || []).find { |tag| tag.match(t) } }
    end

    def heap_match?(executor, message)

      return true if theaps.empty?

      node ||= executor.execution['nodes'][message['nid']]

      return false unless node
      return false if node['removed']

      theaps.include?(node['heap'])
    end

    def heat_match?(executor, message)

      return true if theats.empty?

      node ||= executor.execution['nodes'][message['nid']]

      return false unless node
      return false if node['removed']

      theats.include?(node['heat0'])
    end

    def tpoints; @atpoints ||= split_aval(:tpoints); end
    def ttags; @attags ||= split_aval(:ttags); end
    def theaps; @atheaps ||= split_aval(:theaps); end
    def theats; @atheats ||= split_aval(:theats); end

    protected

    def split_aval(key)

      (@values[key] || '').split(',').collect(&:strip)
    end
  end
end

