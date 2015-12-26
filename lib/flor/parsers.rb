
#--
# Copyright (c) 2015-2015, John Mettraux, jmettraux+flon@gmail.com
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
        h[rewrite(tt.children[0].children[0])] = rewrite(tt.children[4])
        h
      end
    end

    make_includable
  end

  module Radial include Json

# static fabr_tree *_radial(fabr_input *i)
# {
#   return fabr_rep(NULL, i, _rad_line, 0, 0);
# }
    def x(i); str(nil, i, 'x '); end
    def rad_line(i); seq(:rad_line, i, :x, :djan); end
    def radial(i); rep(nil, i, :rad_line, 0); end
  end

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

# // radial
#
# static fabr_tree *_rad_g(fabr_input *i); // forward
#
# static fabr_tree *_rad_p(fabr_input *i)
# {
#   return fabr_seq("rad_p", i,
#     _pstart, _eol, _ws, fabr_star, _rad_g, _eol, _pend,
#     NULL);
# }
#
# static fabr_tree *_rad_v(fabr_input *i)
# {
#   return fabr_alt("rad_v", i, _rxstring, _rad_p, _value, NULL);
# }
#
# static fabr_tree *_rad_k(fabr_input *i)
# {
#   return fabr_alt("rad_k", i, _string, _sqstring, _symbolk, NULL);
# }
#
# static fabr_tree *_rad_kcol(fabr_input *i)
# {
#   return fabr_seq(NULL, i,
#     _rad_k, _ws, fabr_star, _colon, _eol, _ws, fabr_star,
#     NULL);
# }
#
# static fabr_tree *_rad_e(fabr_input *i)
# {
#   return fabr_seq("rad_e", i,
#     //_rad_k, _ws, fabr_star, _colon, _eol, _rad_v,
#     _rad_kcol, fabr_qmark, _rad_v,
#     NULL);
# }
#
# static fabr_tree *_rad_com(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _comma, _eol, NULL);
# }
# static fabr_tree *_rad_comma(fabr_input *i)
# {
#   return fabr_seq(NULL, i,
#     _ws, fabr_star, _rad_com, fabr_qmark, _ws, fabr_star,
#     NULL);
# }
#
# static fabr_tree *_rad_ce(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _rad_comma, _rad_e, NULL);
# }
#
# static fabr_tree *_rad_h(fabr_input *i)
# {
#   return fabr_seq("rad_h", i, _rad_v, NULL);
# }
#
# static fabr_tree *_rad_es(fabr_input *i)
# {
#   return fabr_rep(NULL, i, _rad_ce, 0, 0);
# }
#
# static fabr_tree *_rad_g(fabr_input *i)
# {
#   return fabr_seq("rad_g", i, _rad_h, _rad_es, NULL);
# }
#
# static fabr_tree *_rad_i(fabr_input *i)
# {
#   return fabr_rex("rad_i", i, "[ \t]*");
# }
#
# static fabr_tree *_rad_l(fabr_input *i)
# {
#   return fabr_seq("rad_l", i, _rad_i, _rad_g, NULL);
# }
#
# static fabr_tree *_rad_eol(fabr_input *i)
# {
#   return fabr_rex(NULL, i, "[ \t]*(#[^\n\r]*)?[\n\r]?");
# }
#
# static fabr_tree *_rad_line(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _rad_l, fabr_qmark, _rad_eol, NULL);
# }
#
# static fabr_tree *_radial(fabr_input *i)
# {
#   return fabr_rep(NULL, i, _rad_line, 0, 0);
# }
