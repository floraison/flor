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

  def self.to_djan(x, opts={}); to_d(x, opts); end

  def self.to_d(x, opts={})

    opts[:s] = StringIO.new
    opts[:c] = Flor.colours(opts)

    Djan._to_d(x, opts)

    opts[:s].string
  end

  module Djan
    extend self

    def _to_d(x, opts)

      case x
      when nil then _c_nil(x.to_s, opts)
      when String then _string_to_d(x, opts)
      when Hash then _object_to_d(x, opts)
      when Array then _array_to_d(x, opts)
      when TrueClass then _c_tru(x.to_s, opts)
      when FalseClass then _c_false(x.to_s, opts)
      else _c_num(x.to_s, opts)
      end
    end

    def _len(x, opts)

      opts = opts.merge(
        s: StringIO.new, c: Flor.no_colours, width: nil, newline: false)
      _to_d(x, opts)

      opts[:s].string.length
    end

    def _newline(opts)

      opts[:s] << "\n"
      opts[:s] << (opts[:indent] || 0) * '  '
    end

    def _space(opts, force=false)

      opts[:s] << ' ' if force || ! opts[:compact]
    end

    def _object_to_d(x, opts)

      return _c_inf('{}', opts) if x.empty?

      _c_inf('{', opts)
      if opts[:newline]
        _newline(opts)
      elsif ! opts[:compact]
        _space(opts)
      end

      x.each_with_index do |(k, v), i|
        _string_to_d(k, opts)
        _c_inf(':', opts)
        _space(opts)
        _to_d(v, opts)
        if i < x.size - 1
          _c_inf(',', opts)
          _space(opts)
        end
      end

      if opts[:newline]
        _newline(opts)
      elsif ! opts[:compact]
        _space(opts)
      end
      _c_inf('}', opts)
    end

    def _array_to_d(x, opts)

      return _c_inf('[]', opts) if x.empty?

      _c_inf('[', opts)
      if opts[:newline]
        _newline(opts)
      elsif ! opts[:compact]
        _space(opts)
      end

      x.each_with_index do |e, i|
        _to_d(v, opts)
        if i < x.size - 1
          _c_inf(',', opts)
          _space(opts)
        end
      end

      if opts[:newline]
        _newline(opts)
      elsif ! opts[:compact]
        _space(opts)
      end
      _c_inf(']', opts)
    end

    def _string_to_d(x, opts)

      x = x.to_s

      if (
        x.match(/\A[^: \b\f\n\r\t"',()\[\]{}#\\]+\z/) == nil ||
        x.to_i.to_s == x ||
        x.to_f.to_s == x
      )
        _c_inf('"', opts)
        _c_str(x.inspect[1..-2], opts)
        _c_inf('"', opts)
      else
        _c_str(x, opts)
      end
    end

    def _c_inf(s, opts); opts[:s] << opts[:c].dark_gray(s); end

    def _c_nil(s, opts); opts[:s] << opts[:c].dark_gray(s); end
    def _c_tru(s, opts); opts[:s] << opts[:c].green(s); end
    def _c_fal(s, opts); opts[:s] << opts[:c].red(s); end
    def _c_str(s, opts); opts[:s] << opts[:c].brown(s); end
    def _c_num(s, opts); opts[:s] << opts[:c].light_blue(s); end
  end

#  #
#  # djan
#  #
#  # functions about the "djan" silly version of JSON
#
#  def self.to_djan(x, opts={})
#
#    opts[:cl] =
#      opts[:color] || opts[:colour] || opts[:colours] || opts[:colors]
#
#    r =
#      case x
#      when nil then 'null'
#      when String then string_to_d(x, opts)
#      when Hash then object_to_d(x, opts)
#      when Array then array_to_d(x, opts)
#      when TrueClass then c_tru(x.to_s, opts)
#      when FalseClass then c_tru(x.to_s, opts)
#      else c_num(x.to_s, opts)
#      end
#    if opts[:inner]
#      opts.delete(:inner)
#      r = r[1..-2] if r[0, 1] == '[' || r[0, 1] == '{'
#    end
#    r
#  end
end

