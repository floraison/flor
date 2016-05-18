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

  class UnitExecutor < Flor::Executor

    attr_reader :exid

    def initialize(unit, exid)

      super(unit, unit.storage.load_execution(exid))

      load_procedures('punit')

      @exid = exid
      @messages = unit.storage.fetch_messages(exid)
      @consumed = []
      @alive = true
    end

    def alive?; @alive; end

    def run

      Thread.new { do_run }

      self
    end

    protected

    def do_run

      t0 = Time.now

      (@unit.conf['exe_max_messages'] || 77).times do |i|

        m = @messages.shift
        break unless m

        @unit.log_message(:pre, m)

        point = m['point']

        ms = process(m)

        @consumed << m

        @unit.log_message(:post, m)

        @messages.concat(ms)
      end

      @unit.storage.consume(@consumed)

      @alive = false
        # TODO
p [ self.hash, @exid, :took, Time.now - t0, :consumed, @consumed.size ]; $stdout.flush

      @execution['counters']['runs'] ||= 0
      @execution['counters']['runs'] += 1

      @unit.storage.put_execution(@execution)
      @unit.storage.put_messages(@messages)

    rescue => e
puts "=" * 80
p e
puts e.backtrace
puts ("=" * 80) + ' .'
    end

    def failed(message)

puts " *** failed: " + message.inspect

      []
    end

    def terminated(message)

      # nothing to do

      []
    end

#    def apply(node, message)
#
#      n = Flor::Node.new(@execution, node, message)
#
#      mt = message['tree']
#      nt = n.lookup_tree(node['nid'])
#      node['tree'] = mt if mt && (mt != nt)
#      tree = node['tree'] || nt
#
#      t0 = tree[0]
#      t0 = (t0.is_a?(Array) && t0[0] == '_dqs') ? n.expand(t0[1]) : t0
#
#      heat = n.deref(t0)
#
#      return error_reply(
#        node, message, "don't know how to apply #{tree[0].inspect}"
#      ) if heat == nil
#
#      heak =
#        if ! heat.is_a?(Array)
#          Flor::Pro::Val
#        elsif tree[1] == []
#          Flor::Pro::Val
#        elsif heat[0] == '_proc'
#          Flor::Executor.procedures[heat[1]]
#        elsif heat[0] == '_func'
#          Flor::Pro::Apply
#        else
#          Flor::Pro::Val
#        end
#
#      head = heak.new(@execution, node, message)
#      head.heat = heat if head.respond_to?(:heat=)
#
#      head.send(message['point'])
#    end

#    def receive(message)
#
#      from = message['from']
#
#      fnode = @execution['nodes'][from]
#      if fnode
#        fnode['deleted'] = true # or should I use "status" => "deleted" ?
#        @execution['nodes'].delete(from) if (fnode['closures'] || []).empty?
#      end
#
#      nid = message['nid']
#
#      return [
#        message.merge('point' => 'terminated', 'vars' => (fnode || {})['vars'])
#      ] if nid == nil
#
#      node = @execution['nodes'][nid]
#
#      apply(node, message)
#    end
    def cancel(message)

fail "implement me!"
      []
    end

    def schedule(message)

      @unit.storage.put_timer(message)

      []
    end
  end
end

