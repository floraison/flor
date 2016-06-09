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


class Flor::Pro::Cmp < Flor::Procedure

  names %w[ = == < > ]

  def pre_execute

    @node['rets'] = []
  end

  def do_receive

    payload['ret'] =
      if @node['rets'].size > 1
        case tree[0]
          when '=', '==' then check_equal
          when '<', '>' then check_lesser
          else true
        end
      else
        true
      end

    reply
  end

  protected

  def check_equal

    @node['rets'].first == @node['rets'].last
  end

  def check_lesser

    a, b = @node['rets'][-2], @node['rets'][-1]

    case tree[0]
      when '<' then return false if a >= b
      when '<=' then return false if a > b
      when '>' then return false if a <= b
      when '>=' then return false if a < b
    end

    true
  end
end

