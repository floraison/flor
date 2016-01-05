
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

    attr_reader :storage
    attr_reader :dispatcher
    attr_reader :logger

    def initialize(opts)

      uri = opts[:storage_uri]
      dispatcher = opts[:dispatcher] != false
      logger = opts[:logger] != false

      fail ArgumentError.new('missing :storage_uri option') unless uri

      @options = opts

      @storage = Flor::Storage.new(uri, opts)
      @dispatcher = dispatcher ? Flor::Dispatcher.new(self) : nil
      @logger = logger ? Flor::Logger.new(self) : nil
    end

    def stop

      @dispatcher.stop if @dispatcher
    end

    def wait(exid, point, nid, maxsec=3)

      @logger.wait(exid, point, nid, maxsec)
    end

    def on(exid, point, nid, &block)

      @logger.on(exid, point, nid, &block)
    end

    def launch(domain, tree, payload, variables=nil)

      exid = generate_exid(domain)

      msg = {
        point: 'execute',
        domain: domain,
        exid: exid,
        tree: tree.is_a?(String) ? Flor::Radial.parse(tree) : tree,
        payload: payload,
        vars: variables }

      @storage.store_message(:dispatcher, msg)

      exid
    end

    protected

    def generate_exid(domain)

      @exid_counter ||= 0
      @exid_mutex ||= Mutex.new

      local = true

      uid = 'u0'

      t = Time.now
      t = t.utc unless local

      sus =
        @exid_mutex.synchronize do

          sus = t.sec * 100000000 + t.usec * 100 + @exid_counter

          @exid_counter = @exid_counter + 1
          @exid_counter = 0 if @exid_counter > 99

          Munemo.to_s(sus)
        end

      t = t.strftime('%Y%m%d.%H%M')

      "#{domain}-#{uid}-#{t}.#{sus}"
    end
  end
end

