# frozen_string_literal: true

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

    class << self

      attr_accessor :unit
    end

    def unit; self.class.unit; end
    def storage; unit.storage; end

    # Return a Flor::Execution instance linked to this model
    #
    def execution(reload=false)

      exid = @values[:exid]; return nil unless exid

      @flor_model_cache_execution = nil if reload

      @flor_model_cache_execution ||= unit.executions[exid: exid]
    end

    # Returns the node hash linked to this model
    #
    def node(reload=false)

      nid = @values[:nid]; return nil unless nid
      exe = execution(reload); return nil unless exe

      nodes = exe.data['nodes']; return nil unless nodes
      nodes[nid]
    end

    def payload(reload=false)

      nod = node(reload)
      nod ? nod['payload'] : nil
    end

    def data(cache=true)

      cache ? (@flor_model_cache_data = _data) : _data
    end

    def refresh

      instance_variables
        .each do |k|
          instance_variable_set(k, nil) \
            if k.to_s.start_with?('@flor_model_cache_')
        end

      super
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

    alias to_dump_h to_h
      #
      # Downsteam, #to_h answers are more complete, more standalone
      # whereas, #to_dump_h answers are more compact (see florist).
      # For now, they're just the same, it specializes downstream.

    class << self

      def from_h(h)

        cols = columns

        h
          .inject({}) { |r, (k, v)|
            k = k.to_sym
            if k == :data
              r[:content] = Flor.to_blob(v)
            elsif cols.include?(k)
              r[k] = v
            end
            r }
      end
    end

    protected

    def _data

      d = Flor::Storage.from_blob(content)
      d['id'] = id if d.is_a?(Hash)

      d
    end
  end

  MODELS = [ :executions, :timers, :traces, :traps, :pointers, :messages ]

  dir = File.dirname(__FILE__)
  MODELS.each { |m| require File.join(dir, 'models', "#{m.to_s[0..-2]}.rb") }

  def self.add_model(key, parent_module=Flor, table_prefix='flor_')

    Flor::Storage.send(:define_method, key) do

      s = self
      c = Flor.to_camel_case(key.to_s[0..-2])

      @models[key] ||=
        parent_module.const_set(
          "#{c}#{self.object_id.to_s.gsub('-', 'M')}",
          Class.new(parent_module.const_get(c)) do
            self.dataset = s.db["#{table_prefix}#{key}".to_sym]
            self.unit = s.unit
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

