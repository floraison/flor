
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

  # Black       0;30     Dark Gray     1;30
  # Blue        0;34     Light Blue    1;34
  # Green       0;32     Light Green   1;32
  # Cyan        0;36     Light Cyan    1;36
  # Red         0;31     Light Red     1;31
  # Purple      0;35     Light Purple  1;35
  # Brown       0;33     Yellow        1;33
  # Light Gray  0;37     White         1;37

  def self.c_inf(s, opts); opts[:cl] ? "[1;30m#{s}[0;0m" : s; end
  def self.c_str(s, opts); opts[:cl] ? "[1;33m#{s}[0;0m" : s; end
  def self.c_tru(s, opts); opts[:cl] ? "[0;32m#{s}[0;0m" : s; end
  def self.c_fal(s, opts); opts[:cl] ? "[0;31m#{s}[0;0m" : s; end
  def self.c_num(s, opts); opts[:cl] ? "[1;34m#{s}[0;0m" : s; end

  def self.c_key(s, opts)

    return s unless opts[:cl]

    s.match(/\A".*"\z/) ?
      "#{c_inf('"', opts)}[0;33m#{s[1..-2]}#{c_inf('"', opts)}" :
      "[0;33m#{s}[0;0m"
  end

  def self.string_to_d(x, opts)

    if (
      x.match(/\A[^: \b\f\n\r\t"',()\[\]{}#\\]+\z/) == nil ||
      x.to_i.to_s == x ||
      x.to_f.to_s == x
    )
      "#{c_inf('"', opts)}#{c_str(x.inspect[1..-2], opts)}#{c_inf('"', opts)}"
    else
      c_str(x, opts)
    end
  end

  def self.object_to_d(x, opts)

    a = [ '{ ', ': ', ', ', ' }' ]
    a = a.collect(&:strip) if x.empty? || opts[:compact]
    a = a.collect { |s| c_inf(s, opts) }
    a, b, c, d = a

    a +
    x.collect { |k, v|
      "#{c_key(to_djan(k, {}), opts)}#{b}#{to_djan(v, opts)}"
    }.join(c) +
    d
  end

  def self.array_to_d(x, opts)

    a = [ '[ ', ', ', ' ]' ]
    a = a.collect(&:strip) if x.empty? || opts[:compact]
    a = a.collect { |s| c_inf(s, opts) }
    a, b, c = a

    a + x.collect { |e| to_djan(e, opts) }.join(b) + c
  end

  def self.to_djan(x, opts={})

    opts[:cl] = opts[:color] || opts[:colour]

    case x
      when nil then 'null'
      when String then string_to_d(x, opts)
      when Hash then object_to_d(x, opts)
      when Array then array_to_d(x, opts)
      when TrueClass then c_tru(x.to_s, opts)
      when FalseClass then c_tru(x.to_s, opts)
      else c_num(x.to_s, opts)
    end
  end
end

