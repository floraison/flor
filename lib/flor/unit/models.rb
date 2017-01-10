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

  MODELS = [ :executions, :timers, :traces, :traps ]

  dir = File.dirname(__FILE__)
  MODELS.each { |m| require File.join(dir, 'models', "#{m.to_s[0..-2]}.rb") }

  class Storage

    MODELS.each do |k|

      define_method(k) do

        s = self
        c = k.to_s[0..-2].capitalize

        @models[k] ||=
          Flor.const_set(
            "#{c}#{@db.object_id.to_s.gsub('-', 'M')}",
            Class.new(Flor.const_get(c)) do
              self.dataset = s.db["flor_#{k}".to_sym]
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

