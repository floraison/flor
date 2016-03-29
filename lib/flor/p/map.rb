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


class Flor::Pro::Map < Flor::Procedure

  name 'map'

  def execute

    @node['ret'] = Flor.dup(payload['ret'])
    @node['col'] = nil
    @node['idx'] = -1
    @node['fun'] = nil
    @node['res'] = []

    execute_child(0)
  end

  def receive

    if @node['col'] == nil

      if Flor.is_func?(payload['ret'])
        @node['col'] = Flor.to_coll(@node['ret'])
      else
        @node['col'] = Flor.to_coll(payload['ret'])
        return execute_child(1)
      end
    end

    if @node['idx'] < 0
      @node['fun'] = payload['ret']
    else
      @node['res'] << payload['ret']
    end

    @node['idx'] += 1; @node['mtime'] = Flor.tstamp

    return reply('ret' => @node['res']) \
      if @node['idx'] == @node['col'].size

    apply(@node['fun'], @node['col'][@node['idx'], 1], tree[2])
  end
end

