
module Flor

  class DummySequelAdapter < Sequel::Dataset

    class Db
      def supports_schema_parsing?; false; end
      def transaction(opts={}); yield; end
    end

    def initialize(opts)
      @opts = opts
      @db = Db.new
      @cache = {} # necessary for Sequel >= 4.42.0
    end

    def fetch_rows(sql); yield([]); end
    #DJV
    # add missing methods from dummy adaptor
    def typecast_value_boolean(opts={});true;end
    def test_connection();true;end
    #DJV

    DB = Sequel.connect(:adapter => Flor::DummySequelAdapter)
  end

  class FlorModel < Sequel::Model(DummySequelAdapter::DB)

    self.require_valid_table = false

    def _data

      d = Flor::Storage.from_blob(content)
      d['id'] = id

      d
    end

    def data(cache=true)

      cache ? (@data = _data) : _data
    end

    def to_h

      values.inject({}) do |h, (k, v)|
        if k == :content
          h[:data] = data
        else
          h[k] = v
        end
        h
      end
    end
  end

  MODELS = [ :executions, :timers, :traces, :traps, :pointers, :messages ]

  dir = File.dirname(__FILE__)
  MODELS.each { |m| require File.join(dir, 'models', "#{m.to_s[0..-2]}.rb") }

  def self.add_model(key, parent_module=Flor, table_prefix='flor_')

    Flor::Storage.send(:define_method, key) do

      s = self
      c = key.to_s[0..-2].capitalize

      @models[key] ||=
        parent_module.const_set(
          "#{c}#{@db.object_id.to_s.gsub('-', 'M')}",
          Class.new(parent_module.const_get(c)) do
            self.dataset = s.db["#{table_prefix}#{key}".to_sym]
          end)
    end

    Flor::Scheduler.send(:define_method, key) do

      @storage.send(key)
    end
  end

  MODELS.each do |k|

    add_model(k)
  end
end

