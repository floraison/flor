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


class Flor::Pro::Until < Flor::Procedure

  names %w[ until while ]

  def execute

    @node['count'] = 1

    execute_child(0, @node['count'])
  end

  def receive

    fid = Flor.child_id(from)
    @node['mtime'] = Flor.tstamp

    if fid == 0

      t0 = tree[0]
      tru = Flor.true?(payload['ret'])

      if (tru && t0 == 'until') || ( ! tru && t0 == 'while')
        reply('ret' => @node['ret'])
      else
        @node['count'] += 1
        execute_child(1, @node['count'])
      end

    else

      @node['ret'] = Flor.dup(payload['ret'])

      fnid = fid + 1
      fnid = 0 if tree[1][fnid] == nil

      execute_child(fnid, @node['count'])
    end
  end
end

