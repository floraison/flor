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

  class Execution < FlorModel

    def nodes; data['nodes']; end
    def tags; self.class.tags(data); end

    def failed?

      !! nodes.values
        .find { |n| n['failure'] && n['status'] != 'triggered-on-error' }
    end

    # class methods

    def self.by_status(s)

      self.where(status: s)
    end

    def self.terminated

      by_status('terminated')
    end

    def self.by_tag(name)

      exids = self.db[:flor_pointers]
        .where(type: 'tag', name: name, value: nil)
        .select(:exid)
        .distinct

      self.where(status: 'active', exid: exids)
    end

    def self.by_var(name, value=:no)

      w = { type: 'var', name: name }
      w[:value] = value.to_s if value != :no # nil is OK

      exids = self.db[:flor_pointers]
        .where(w)
        .select(:exid)
        .distinct

      self.where(status: 'active', exid: exids)
    end

    def self.tags(data)

      data['nodes'].values.inject([]) do |a, n|
        if ts = n['tags']; a.concat(ts); end
        a
      end
    end
  end
end

