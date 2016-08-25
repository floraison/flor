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

  class DummySequelAdapter < Sequel::Dataset

    class Db
      def supports_schema_parsing?; false; end
      def transaction(opts={}); yield; end
    end

    def initialize(opts)
      @opts = opts
      @db = Db.new
    end

    def fetch_rows(sql); yield([]); end

    DB = Sequel.connect(:adapter => Flor::DummySequelAdapter)
  end

  class FlorModel < Sequel::Model(DummySequelAdapter::DB)

    def _data

      d = Flor::Storage.from_blob(content)
      d['id'] = id

      d
    end

    def data(cache=true)

      cache ? (@data = _data) : _data
    end
  end

  class Execution < FlorModel

    def self.terminated

      self.where(status: 'terminated')
    end
  end

  class Timer < FlorModel

    def to_trigger_message

      m = self.data(false)['message']
      m['timer_id'] = self.id

      {
        'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.nid,
        'type' => self.type,
        'schedule' => self.schedule,
        'timer_id' => self.id,
        'message' => m
      }
    end

    # countering tstamp being a String with jdbc sqlite...
    #
    def ntime_t

      @ntime_t ||= (ntime.is_a?(String) ? Time.parse(ntime) : ntime)
    end
  end

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

      #return false if status != 'active' # or...
      #fail if status != 'active'
        # shouldn't happen

      return false if in_trap_itself?(executor, message)

      return false unless domain_match?(message)
      return false unless nid_match?(message)
      return false unless point_match?(message)
      return false unless tag_match?(message)

      return false unless heap_match?(executor, message)
      return false unless heat_match?(executor, message)

      true
    end

    def domain_match?(message)

      case texe
        when 'domain' then Flor.domain(message['exid']) == domain
        when 'subdomain' then true # TODO
        else message['exid'] == exid # 'self'
      end
    end

    def in_trap_itself?(executor, message)

      i = message['nid']

      loop do
        break unless i
        return true if i == nid
        node = executor.execution['nodes'][i]
        i = (node || {})['parent']
      end

      false
    end

    def nid_match?(message)

      tnids.empty? ||
      tnids.include?(message['point'])
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

    def tpoints

      @atpoints ||= (@values[:tpoints] || '').split(',').collect(&:strip)
    end

    def ttags

      @attags ||= (@values[:ttags] || '').split(',').collect(&:strip)
    end

    def tnids

      @atnids ||= (@values[:tnids] || '').split(',').collect(&:strip)
    end

    def theaps

      @atheaps ||= (@values[:theaps] || '').split(',').collect(&:strip)
    end

    def theats

      @atheats ||= (@values[:theats] || '').split(',').collect(&:strip)
    end
  end

  class Trace < FlorModel
  end

  #class Task < Sequel::Model(DummySequelAdapter::DB)
  #end

  MODELS = [ :executions, :timers, :traps, :traces ]

  class Storage

    MODELS.each do |k|

      define_method(k) do

        s = self
        c = k.to_s[0..-2].capitalize

        @models[k] ||=
          Flor.const_set(
            "#{c}#{@db.hash.to_s.gsub('-', 'M')}",
            Class.new(Flor.const_get(c)) do
              self.dataset = s.db["flon_#{k}".to_sym]
            end)
      end
    end
  end

  class Scheduler

    MODELS.each do |k|

      define_method(k) { @storage.send(k) }
    end
  end
end

