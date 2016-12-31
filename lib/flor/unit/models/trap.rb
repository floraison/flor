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


module Flor

  class Trap < FlorModel

    def to_hook

      @hook ||=
        begin

          opts = {}

          opts[:consumed] = tconsumed

          opts[:point] = tpoints.split(',') if tpoints
          opts[:heap] = theaps.split(',') if theaps
          opts[:heat] = theats.split(',') if theats

          opts[:name] = data['names']

          case trange
            when 'execution'
              opts[:exid] = exid
            when 'subdomain'
              opts[:subdomain] = Flor.domain(exid)
            when 'domain'
              opts[:domain] = Flor.domain(exid)
            else #'subnid' # default
              opts[:exid] = exid
              opts[:subnid] = true
          end

          [ "trap#{id}", opts, self, nil ]
        end
    end

    def trigger(executor, message)

      [ decrement, [ to_trigger_message(executor, message) ] ]
    end

    def within_itself?(executor, message)

      return false if message['exid'] != exid

      n = executor.node(message['from'] || message['nid'], true)
      return false if n == nil

      n.descendant_of?(onid)
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

      dat = self.data(false)
      msg = dat['message']

      msg['trap_id'] = self.id

      if vs = msg['vars']
        k = vs.keys.find { |k| k != 'arguments' } || 'msg'
        vs[k] = message
      end

      #xx = executor.counter_next('xx')
      #msg['dbg'] = xx

      if dat['flavour'] == 'punit/on'
        pl = msg['payload']
        msg['payload'] = Flor.dup(message['payload'])
        (msg['vars'] ||= {})['_payload'] = pl
      end

      {
        'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.nid,
        'type' => 'trap',
        'trap' => to_hash,
        'trap_id' => self.id,
        'message' => msg,
        #'dbg' => xx
      }#.tap { |m| pp m }
    end

    def to_hash

      values.inject({}) { |h, (k, v)| h[k.to_s ] = v if k != :content; h }
    end
  end
end

