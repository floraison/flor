
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

require 'raabro'


module Flor

  module Json include Raabro

    make_includable

    # parsing

    def shacom(i); rex(nil, i, /#[^\r\n]*/); end
    def slacom(i); rex(nil, i, /\/\/[^\r\n]*/); end
    def com(i); alt(nil, i, :shacom, :slacom); end

    def comma(i); str(nil, i, ','); end

    def ws(i); rex(nil, i, /[ \t]/); end
    def rn(i); rex(nil, i, /[\r\n]/); end
    def colon(i); str(nil, i, ':'); end

    def eol(i); seq(nil, i, :ws, '*', :com, '?', :rn, '*'); end

    def dol(i); rex(nil, i, /[^ \r\n\t\\)]+/); end
    def dolstart(i); str(nil, i, '$('); end
    def symcore(i); rex(nil, i, /[^: \b\f\n\r\t"',()\[\]{}#\\]+/); end
    def symdol(i); seq(nil, i, :dolstart, :dol, :pend); end
    def symelt(i); alt(nil, i, :symdol, :symcore, :colon); end
    def symeltk(i); alt(nil, i, :symdol, :symcore); end

    def symbol(i); rep(:symbol, i, :symelt, 1); end
    def symbolk(i); rep(:symbolk, i, :symeltk, 1, 0); end

    def null(i); str(:null, i, 'null'); end
    def tru(i); str(:true, i, 'true'); end
    def fls(i); str(:false, i, 'false'); end

    def number(i); rex(:number, i, /-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?/); end

    def string(i)

      rex(:string, i, %r{
        "(
          \\["bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^"\\\b\f\n\r\t]
        )*"
      }x)
    end

    def sqstring(i)

      rex(:string, i, %r{
        '(
          \\['bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*'
      }x)
    end

    def postval(i); rep(nil, i, :eol, 0); end

    def sep(i); seq(nil, i, :comma, '?', :postval); end

    def val_qmark(i); rep(nil, i, :val, 0, 1); end

    def sbstart(i); str(nil, i, '['); end
    def sbend(i); str(nil, i, ']'); end

    def array(i); eseq(:array, i, :sbstart, :val_qmark, :sep, :sbend); end

    def key(i); alt(:key, i, :string, :sqstring, :symbolk); end

    def entry(i); seq(:entry, i, :key, :postval, :colon, :postval, :value, :postval); end
    def entry_qmark(i); rep(nil, i, :entry, 0, 1); end

    def pbstart(i); str(nil, i, '{'); end
    def pbend(i); str(nil, i, '}'); end

    def object(i); eseq(:object, i, :pbstart, :entry_qmark, :sep, :pbend); end

    def v(i); alt(nil, i, :string, :sqstring, :number, :object, :array, :tru, :fls, :null); end
    def value(i); altg(nil, i, :symbol, :v); end

    def val(i); seq(nil, i, :value, :postval); end
    def postval(i); seq(nil, i, :eol, '*'); end

    def djan(i); seq(nil, i, :postval, :val); end

    # rewriting

    def rewrite_null(t); nil; end

    def rewrite_true(t); true; end
    def rewrite_false(t); false; end

    def rewrite_number(t)
      s = t.string
      s.index('.') ? s.to_f : s.to_i
    end

    def rewrite_string(t); Flor.unescape(t.string[1..-2]); end
    def rewrite_symbol(t); t.string; end
    def rewrite_symbolk(t); t.string; end

    def rewrite_array(t); t.subgather(nil).collect { |n| rewrite(n) }; end

    def rewrite_object(t);
      t.subgather(nil).inject({}) do |h, tt|
        h[rewrite(tt.c0.c0)] = rewrite(tt.c4)
        h
      end
    end
  end # module Json

  module Radial include Json

    # parsing

    def rxstring(i)

      rex(:rxstring, i, %r{
        /(
          \\[\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*/[a-z]*
      }x)
    end

    def pstart(i); str(nil, i, '('); end
    def pend(i); str(nil, i, ')'); end

    def rad_p(i); seq(:rad_p, i, :pstart, :eol, :ws, '*', :rad_g, :eol, :pend); end
    def rad_v(i); alt(:rad_v, i, :rxstring, :rad_p, :value); end
    def rad_k(i); alt(:rad_k, i, :string, :sqstring, :symbolk); end
    def rad_kcol(i); seq(nil, i, :rad_k, :ws, '*', :colon, :eol, :ws, '*'); end
    def rad_e(i); seq(:rad_e, i, :rad_kcol, '?', :rad_v); end
    def rad_com(i); seq(nil, i, :comma, :eol); end
    def rad_comma(i); seq(nil, i, :ws, '*', :rad_com, '?', :ws, '*'); end
    def rad_ce(i); seq(nil, i, :rad_comma, :rad_e); end
    def rad_h(i); seq(:rad_h, i, :rad_v); end # ?
    def rad_es(i); rep(nil, i, :rad_ce, 0); end
    def rad_g(i); seq(:rad_g, i, :rad_h, :rad_es); end
    def rad_i(i); rex(:rad_i, i, /[ \t]*/); end
    def rad_eol(i); rex(nil, i, /[ \t]*(#[^\n\r]*)?[\n\r]?/); end

    def rad_l(i); seq(:rad_l, i, :rad_i, :rad_g); end

    def rad_line(i); seq(nil, i, :rad_l, '?', :rad_eol); end
    def radial(i); rep(:radial, i, :rad_line, 0); end

    # rewriting

    def rewrite_rxstring(t)

      ::Kernel.eval(t.string) # :-(
    end

    def rewrite_rad_p(t)

      Line.new(t).to_a
    end

    class Line

      attr_reader :indent, :children
      attr_accessor :parent

      def initialize(t)

        @parent = nil
        @children = []
        @indent = -1

        if t

          gt = t.lookup(:rad_g)
          lin = gt.input.string[0..gt.offset].scan("\n").count + 1

          if it = t.lookup(:rad_i)
            @indent = it.string.length
          end

          atts = {}

          vt = t.lookup(:rad_h).lookup(:rad_v).sublookup(nil)

          nam = 'val'
          if vt.name == :symbol || vt.name == :string
            nam = vt.string
          elsif vt.name == :rad_p
            nam = Flor::Radial.rewrite(vt)
          else
            nam = [ 'val', { '_0' => Flor::Radial.rewrite(vt) }, lin, [] ]
          end

          t.lookup(:rad_g).c1.gather(:rad_e).each_with_index do |et, i|

            kt = et.lookup(:rad_k)
            vt = et.lookup(:rad_v)

            k = kt ? Flor::Radial.rewrite(kt.c0) : "_#{i}"
            v = Flor::Radial.rewrite(vt.c0)

            atts[k] = v
          end

          @a = (nam.is_a?(Array) && atts.empty?) ? nam : [ nam, atts, lin ]

        else

          @a = [ 'sequence', {}, 0 ]
        end
      end

      def to_a

        [ *@a[0, 3], @children ]
      end

      def append(line)

        if line.indent > self.indent
          @children << line.to_a
          line.parent = self
        else
          @parent.append(line)
        end
      end
    end # class Line

    def rewrite_radial(t)

      root = Line.new(nil)
      prev = root

      t.gather(:rad_l).each do |lt|
        l = Line.new(lt)
        prev.append(l)
        prev = l
      end

      return root.children.first.to_a if root.children.count == 1

      root.to_a
    end

    def parse(input, fname=nil, opts={})

      opts = fname if fname.is_a?(Hash) && opts.empty?

      r = super(input, opts)
      r << fname if fname

      r
    end
  end # module Radial

  def self.unescape_u(cs)

    s = ''; 4.times { s << cs.next }

    [ s.to_i(16) ].pack('U*')
  end

  def self.unescape(s)

    sio = StringIO.new

    cs = s.each_char

    loop do

      c = cs.next

      break unless c

      if c == '\\'
        case cn = cs.next
          when 'u' then sio.print(unescape_u(cs))
          when '\\', '"', '\'' then sio.print(cn)
          when 'b' then sio.print("\b")
          when 'f' then sio.print("\f")
          when 'n' then sio.print("\n")
          when 'r' then sio.print("\r")
          when 't' then sio.print("\t")
          else sio.print("\\#{cn}")
        end
      else
        sio.print(c)
      end
    end

    sio.string
  end
end

