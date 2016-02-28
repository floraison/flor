
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

  def self.dup(o)

    Marshal.load(Marshal.dump(o))
  end

  def self.tstamp(t=Time.now.utc)

    t.strftime('%Y%m%d.%H%M%S') + sprintf('%06d', t.usec)
  end

  def self.to_error(o)

    if o.respond_to?(:message)
      { 'msg' => o.message,
        'kla' => o.class.to_s,
        'trc' => o.backtrace[0, 7] }
    else
      { 'msg' => o.to_s }
    end
  end

  def self.is_tree?(o)

    o.is_a?(Array) &&
    (o[0].is_a?(String) || is_tree?(o[0])) &&
    o[1].is_a?(Hash) &&
    o[2].is_a?(Fixnum) &&
    o[3].is_a?(Array) &&
    o[3].all? { |e| is_tree?(e) } # overkill?
  end

  def self.is_val?(o)

    o.is_a?(Array) &&
    o[0] == 'val' &&
    o[1].is_a?(Hash) &&
    o[2].is_a?(Fixnum) &&
    o[3] == []
  end

  def self.is_string_val?(o)

    o.is_a?(Array) &&
    o[0] == 'val' &&
    o[1].is_a?(Hash) &&
    %w[ sqstring dqstring ].include?(o[1]['t']) &&
    o[1]['v'].is_a?(String) &&
    o[2].is_a?(Fixnum) &&
    o[3] == []
  end

  def self.to_r(val)

    return val unless is_val?(val)

    if val[1]['t'] == 'rxstring'
      Kernel.eval(val[1]['v']) # FIXME !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    else
      val[1]['v']
    end
  end

  def self.de_val(o)

    if is_val?(o)
      o[1]['v']
    else
      o
    end
  end
end

