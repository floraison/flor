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


module Flor::Ash

  ASH_KEYS = %w[ payload ]

  def ash_value(value)

    return value if value.is_a?(String)

    "SHA256:#{Digest::SHA256.hexdigest(JSON.dump(value))}"
  end

  def unash_value(code, copy=false)

    return (copy ? Flor.dup(code) : code) unless code.is_a?(String)

    c0, c1 = code.index(':'), code.rindex(':')

    r =
      if c1 > c0
        (@execution['ashes'][code[0..c1 - 1]] || {})[code[c1 + 1..-1]]
      else
        @execution['ashes'][code]
      end

    copy ? Flor.dup(r) : r
  end

  def ash_all!(h)

    ASH_KEYS.each { |k| ash!(h, k) }

    h
  end

  def unash_all!(h)

    ASH_KEYS.each { |k| unash!(h, k) }

    h
  end

  def ash!(h, key, subkey=nil)

    v = h[key]
    a = ash_value(v)

    @execution['ashes'][a] = Flor.deep_freeze(v) \
      unless @execution['ashes'].has_key?(a)

    subkey ? "#{a}:#{subkey}" : a
  end

  def unash(h, key)

    unash_value(h[key])
  end

  def unash!(h, key, copy=false)

    code = h[key]

    if code.is_a?(String)
      h[key] = unash_value(code, copy)
    elsif copy && code.frozen?
      h[key] = Flor.dup(code)
    else
      code
    end
  end
end

