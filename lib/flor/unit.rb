
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

  class Unit

    def initialize(opts)

      uri = opts[:storage_uri]
      clean = opts[:storage_clean]
      dispatcher = opts[:dispatcher] != false

      fail ArgumentError.new('missing :storage_uri option') unless uri

      @options = opts

      @storage = Sequel.connect(uri)
      Flor::Db.delete_tables(@storage) if clean

      @dispatcher = dispatcher ? Dispatcher.new(self) : nil
    end

    def stop

      @dispatcher.stop if @dispatcher
    end

    def list_schedules

      [] # TODO
    end

    def wait(exid, point, opts={}) # :nid, :maxsec

      nil
    end
  end
end

require 'flor/unit/storage'
require 'flor/unit/launch'

