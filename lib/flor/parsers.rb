
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

# static fabr_tree *_ws(fabr_input *i) { return fabr_rng(NULL, i, " \t"); }
# static fabr_tree *_rn(fabr_input *i) { return fabr_rng(NULL, i, "\r\n"); }
# static fabr_tree *_comma(fabr_input *i) { return fabr_str(NULL, i, ","); }
#
# static fabr_tree *_shacom(fabr_input *i)
# {
#   return fabr_rex(NULL, i, "#[^\r\n]*");
# }
# static fabr_tree *_slacom(fabr_input *i)
# {
#   return fabr_rex(NULL, i, "//[^\r\n]*");
# }
# static fabr_tree *_com(fabr_input *i)
# {
#   return fabr_alt(NULL, i, _shacom, _slacom, NULL);
# }
# static fabr_tree *_eol(fabr_input *i)
# {
#   return fabr_seq(NULL, i,
#     _ws, fabr_star, _com, fabr_qmark, _rn, fabr_star,
#     NULL);
# }
#
# static fabr_tree *_postval(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _eol, fabr_star, NULL);
# }
#
# static fabr_tree *_sep(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _comma, fabr_qmark, _postval, NULL);
# }
#
# static fabr_tree *_value(fabr_input *i); // forward
#
# static fabr_tree *_string(fabr_input *i)
# {
#   return fabr_rex("string", i,
#     "\""
#       "("
#         "\\\\[\"\\/\\\\bfnrt]" "|"
#         "\\\\u[0-9a-fA-F]{4}" "|"
#         "[^"
#           "\"" "\\\\" /*"\\/"*/ "\b" "\f" "\n" "\r" "\t"
#         "]"
#       ")*"
#     "\"");
# }
# static fabr_tree *_sqstring(fabr_input *i)
# {
#   return fabr_rex("sqstring", i,
#     "'"
#       "("
#         "\\\\['\\/\\\\bfnrt]" "|"
#         "\\\\u[0-9a-fA-F]{4}" "|"
#         "[^"
#           "'" "\\\\" /*"\\/"*/ "\b" "\f" "\n" "\r" "\t"
#         "]"
#       ")*"
#     "'");
# }
# static fabr_tree *_rxstring(fabr_input *i)
# {
#   return fabr_rex("rxstring", i,
#     "/"
#       "("
#         "\\\\['\\/\\\\bfnrt]" "|"
#         "\\\\u[0-9a-fA-F]{4}" "|"
#         "[^"
#           "/" "\\\\" "\b" "\f" "\n" "\r" "\t"
#         "]"
#       ")*"
#     "/i?");
# }
#
# static fabr_tree *_colon(fabr_input *i) { return fabr_str(NULL, i, ":"); }
# static fabr_tree *_dolstart(fabr_input *i) { return fabr_str(NULL, i, "$("); }
# static fabr_tree *_pstart(fabr_input *i) { return fabr_str(NULL, i, "("); }
# static fabr_tree *_pend(fabr_input *i) { return fabr_str(NULL, i, ")"); }
#
# static fabr_tree *_symcore(fabr_input *i)
# {
#   return fabr_rex(NULL, i, "[^: \b\f\n\r\t\"',\\(\\)\\[\\]\\{\\}#\\\\]+");
# }
#
# static fabr_tree *_dol(fabr_input *i)
# {
#   return fabr_rex(NULL, i, "[^ \r\n\t\\)]+");
# }
#
# static fabr_tree *_symdol(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _dolstart, _dol, _pend, NULL);
# }
#
# static fabr_tree *_symeltk(fabr_input *i)
# {
#   return fabr_alt(NULL, i, _symdol, _symcore, NULL);
# }
# static fabr_tree *_symelt(fabr_input *i)
# {
#   return fabr_alt(NULL, i, _symdol, _symcore, _colon, NULL);
# }
#
# static fabr_tree *_symbolk(fabr_input *i)
# {
#   return fabr_rep("symbolk", i, _symeltk, 1, 0);
# }
# static fabr_tree *_symbol(fabr_input *i)
# {
#   return fabr_rep("symbol", i, _symelt, 1, 0);
# }
#
# static fabr_tree *_number(fabr_input *i)
# {
#   return fabr_rex("number", i, "-?[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?");
# }
#
# static fabr_tree *_val(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _value, _postval, NULL);
# }
# static fabr_tree *_val_qmark(fabr_input *i)
# {
#   return fabr_rep(NULL, i, _val, 0, 1);
# }
#
# static fabr_tree *_key(fabr_input *i)
# {
#   return fabr_alt("key", i, _string, _sqstring, _symbolk, NULL);
# }
#
# static fabr_tree *_entry(fabr_input *i)
# {
#   return fabr_seq("entry", i,
#     _key, _postval, _colon, _postval, _value, _postval,
#     NULL);
# }
# static fabr_tree *_entry_qmark(fabr_input *i)
# {
#   return fabr_rep(NULL, i, _entry, 0, 1);
# }
#
# static fabr_tree *_pbstart(fabr_input *i) { return fabr_str(NULL, i, "{"); }
# static fabr_tree *_pbend(fabr_input *i) { return fabr_rex(NULL, i, "}"); }
#
# static fabr_tree *_object(fabr_input *i)
# {
#   return fabr_eseq("object", i, _pbstart, _entry_qmark, _sep, _pbend);
# }
# static fabr_tree *_bjec(fabr_input *i)
# {
#   return fabr_jseq("object", i, _entry_qmark, _sep);
# }
# static fabr_tree *_ob(fabr_input *i)
# {
#   return fabr_alt(NULL, i, _object, _bjec, NULL);
# }
# static fabr_tree *_obj(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _postval, _ob, _postval, NULL);
# }
#
# static fabr_tree *_sbstart(fabr_input *i) { return fabr_str(NULL, i, "["); }
# static fabr_tree *_sbend(fabr_input *i) { return fabr_str(NULL, i, "]"); }
#
# static fabr_tree *_array(fabr_input *i)
# {
#   return fabr_eseq("array", i, _sbstart, _val_qmark, _sep, _sbend);
# }
#
# static fabr_tree *_true(fabr_input *i) { return fabr_str("true", i, "true"); }
# static fabr_tree *_false(fabr_input *i) { return fabr_str("false", i, "false"); }
# static fabr_tree *_null(fabr_input *i) { return fabr_str("null", i, "null"); }
#
# static fabr_tree *_v(fabr_input *i)
# {
#   return fabr_alt(NULL, i,
#     _string, _sqstring, _number, _object, _array, _true, _false, _null,
#     NULL);
# }
#
# static fabr_tree *_value(fabr_input *i)
# {
#   return fabr_altg(NULL, i, _symbol, _v, NULL);
# }
#
# static fabr_tree *_djan(fabr_input *i)
# {
#   return fabr_seq(NULL, i, _postval, _val, NULL);
# }

module Flor

  module Json include Raabro

    # parsing

    def shacom(i); rex(nil, i, /#[^\r\n]*/); end
    def slacom(i); rex(nil, i, /\/\/[^\r\n]*/); end
    def com(i); alt(nil, i, :shacom, :slacom); end

    def ws(i); rex(nil, i, /[ \t]/); end
    def rn(i); rex(nil, i, /[\r\n]/); end
    def colon(i); str(nil, i, ':'); end

    def eol(i); seq(nil, i, :ws, '*', :com, '?', :rn, '*'); end

    def dol(i); rex(nil, i, /[^ \r\n\t\\)]+/); end
    def dolstart(i); str(nil, i, '$('); end
    def symcore(i); rex(nil, i, /[^: \b\f\n\r\t\"',\\(\\)\\[\\]\\{\\}#\\\\]+/); end
    def symdol(i); seq(nil, i, :dolstart, :dol, :pend); end
    def symelt(i); alt(nil, i, :symdol, :symcore, :colon); end

    def symbol(i); rep(:symbol, i, :symelt, 1); end

    def number(i); rex(:number, i, /-?[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?/); end

# static fabr_tree *_string(fabr_input *i)
# {
#   return fabr_rex("string", i,
#     "\""
#       "("
#         "\\\\[\"\\/\\\\bfnrt]" "|"
#         "\\\\u[0-9a-fA-F]{4}" "|"
#         "[^"
#           "\"" "\\\\" /*"\\/"*/ "\b" "\f" "\n" "\r" "\t"
#         "]"
#       ")*"
#     "\"");
# }
# static fabr_tree *_sqstring(fabr_input *i)
# {
#   return fabr_rex("sqstring", i,
#     "'"
#       "("
#         "\\\\['\\/\\\\bfnrt]" "|"
#         "\\\\u[0-9a-fA-F]{4}" "|"
#         "[^"
#           "'" "\\\\" /*"\\/"*/ "\b" "\f" "\n" "\r" "\t"
#         "]"
#       ")*"
#     "'");
# }

    #def v(i); alt(nil, i, :string, :sqstring, :number, :object, :array, :true, :false, :null); end
    def v(i); alt(nil, i, :number); end
    #def value(i); altg(nil, i, :symbol, :v); end
    def value(i); altg(nil, i, :symbol, :v); end

    def val(i); seq(nil, i, :value, :postval); end
    def postval(i); seq(nil, i, :eol, '*'); end

    def djan(i); seq(nil, i, :postval, :val); end

    # rewriting

    def rewrite_number(t); t.string.to_i; end
  end

  module Radial

    # TODO
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
