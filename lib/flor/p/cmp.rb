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

  names %w[ = ]

  FULL_NAMES = { '=' => :eq }

  def execute

    @node['rets'] = []

    receive
  end

  def receive

    ms = sequence_receive

    m = ms.size == 1 && ms.first
    #
    if m['point'] == 'receive' && m['nid'] == parent

      payload['ret'] =
        if @node['rets'].empty?
          true
        else
          send(
            "#{@node['rets'].first.class.to_s.downcase}_#{FULL_NAMES[tree[0]]}",
            @node['rets'])
        end
    end

    ms
  end

  protected

  def generic_eq(rets)

    rets.inject(rets[0]) { |e0, e| return false if e != e0; e0 }
    true
  end

  def f_to_s(n)

    n.to_f.to_s
  end

  def float_eq(rets)

    rets.inject(f_to_s(rets[0])) { |e0, e| return false if f_to_s(e) != e0; e0 }
    true
  end

  alias hash_eq generic_eq
  alias array_eq generic_eq
  alias string_eq generic_eq
  alias fixnum_eq generic_eq
  alias nilclass_eq generic_eq
  alias trueclass_eq generic_eq
  alias falseclass_eq generic_eq
end

