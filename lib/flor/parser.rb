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

  module Rad include Raabro

    # parsing

    def null(i); str(:null, i, 'null'); end
    def number(i); rex(:number, i, /-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?/); end

    def tru(i); str(nil, i, 'true'); end
    def fls(i); str(nil, i, 'false'); end
    def boolean(i); alt(:boolean, i, :tru, :fls); end

    def dqstring(i)

      rex(:dqstring, i, %r{
        "(
          \\["bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^"\\\b\f\n\r\t]
        )*"
      }x)
    end

    def sqstring(i)

      rex(:sqstring, i, %r{
        '(
          \\['bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*'
      }x)
    end

    def rxstring(i)

      rex(:rxstring, i, %r{
        /(
          \\[\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*/[a-z]*
      }x)
    end

    def symbol(i); rex(:symbol, i, /[^:; \b\f\n\r\t"',()\[\]{}#\\]+/); end

    def comment(i); rex(nil, i, /#[^\r\n]*/); end

    #def ws_plus(i); rex(nil, i, /[ \t]+/); end
    def ws_star(i); rex(nil, i, /[ \t]*/); end
    def retnew(i); rex(nil, i, /[\r\n]*/); end
    def colon(i); str(nil, i, ':'); end
    def comma(i); str(nil, i, ','); end
    def bslash(i); str(nil, i, '\\'); end

    def pstart(i); str(nil, i, '('); end
    def pend(i); str(nil, i, ')'); end
    def sbstart(i); str(nil, i, '['); end
    def sbend(i); str(nil, i, ']'); end
    def pbstart(i); str(nil, i, '{'); end
    def pbend(i); str(nil, i, '}'); end

    def eol(i); seq(nil, i, :ws_star, :comment, '?', :retnew); end
    def postval(i); rep(nil, i, :eol, 0); end

    def comma_eol(i); seq(nil, i, :comma, :eol, :ws_star); end
    def bslash_eol(i); seq(nil, i, :bslash, :eol, :ws_star); end
    def sep(i); alt(nil, i, :comma_eol, :bslash_eol, :ws_star); end

    def comma_qmark_eol(i); seq(nil, i, :comma, '?', :eol); end
    def coll_sep(i); alt(nil, i, :bslash_eol, :comma_qmark_eol, :ws_star); end

    def ent(i)
      seq(:ent, i, :key, :postval, :colon, :postval, :exp, :postval)
    end
    def ent_qmark(i); rep(nil, i, :ent, 0, 1); end

    def exp_qmark(i); rep(nil, i, :exp, 0, 1); end

    def obj(i); eseq(:obj, i, :pbstart, :ent_qmark, :coll_sep, :pbend); end
    def arr(i); eseq(:arr, i, :sbstart, :exp_qmark, :coll_sep, :sbend); end

    def par(i)
      seq(:par, i, :pstart, :eol, :ws_star, :grp, :eol, :pend)
    end

    def val(i)
      altg(:val, i,
        :par,
        :symbol, :sqstring, :dqstring, :rxstring,
        :arr, :obj,
        :number, :boolean, :null)
    end
    def val_ws(i); seq(nil, i, :val, :ws_star); end

    # precedence
    #  %w[ or or ], %w[ and and ],
    #  %w[ equ == != <> ], %w[ lgt < > <= >= ], %w[ sum + - ], %w[ prd * / % ],

    def ssprd(i); rex(:sop, i, /[\*\/%]/); end
    def sssum(i); rex(:sop, i, /[+-]/); end
    def sslgt(i); rex(:sop, i, /(<=?|>=?)/); end
    def ssequ(i); rex(:sop, i, /(==?|!=|<>)/); end
    def ssand(i); str(:sop, i, 'and'); end
    def ssor(i); str(:sop, i, 'or'); end

    def sprd(i); seq(nil, i, :ssprd, :eol, '?'); end
    def ssum(i); seq(nil, i, :sssum, :eol, '?'); end
    def slgt(i); seq(nil, i, :sslgt, :eol, '?'); end
    def sequ(i); seq(nil, i, :ssequ, :eol, '?'); end
    def sand(i); seq(nil, i, :ssand, :eol, '?'); end
    def sor(i); seq(nil, i, :ssor, :eol, '?'); end

    def eprd(i); jseq(:exp, i, :val_ws, :sprd); end
    def esum(i); jseq(:exp, i, :eprd, :ssum); end
    def elgt(i); jseq(:exp, i, :esum, :slgt); end
    def eequ(i); jseq(:exp, i, :elgt, :sequ); end
    def eand(i); jseq(:exp, i, :eequ, :sand); end
    def eor(i); jseq(:exp, i, :eand, :sor); end

    alias exp eor

    def key(i); alt(:key, i, :dqstring, :sqstring, :symbol); end
      # TODO eventually, accept anything and stringify...

    def kcol(i); seq(nil, i, :key, :ws_star, :colon, :eol); end
    def elt(i); seq(:elt, i, :kcol, '?', :exp); end
    def el(i); seq(nil, i, :sep, :elt); end
    def elts(i); rep(:elts, i, :el, 0); end
    def hed(i); seq(:hed, i, :exp); end
    def grp(i); seq(:grp, i, :hed, :elts); end
    def ind(i); rex(:ind, i, /[; \t]*/); end

    def lin(i); seq(:lin, i, :ind, :grp); end

    def line(i); seq(nil, i, :lin, '?', :eol); end
    def radial(i); rep(:radial, i, :line, 0); end

    # rewriting

    def line_number(t)

      t.input.string[0..t.offset].scan("\n").count + 1
    end
    alias ln line_number

    def rewrite_symbol(t); [ t.string, [], ln(t) ]; end
    alias rewrite_symbolk rewrite_symbol

    def rewrite_sqstring(t); [ '_sqs', t.string[1..-2], ln(t) ]; end
    def rewrite_dqstring(t); [ '_dqs', t.string[1..-2], ln(t) ]; end
    def rewrite_rxstring(t); [ '_rxs', t.string, ln(t) ]; end

    def rewrite_number(t)

      s = t.string; [ '_num', s.index('.') ? s.to_f : s.to_i, ln(t) ]
    end

    def rewrite_boolean(t); [ '_boo', t.string == 'true', line_number(t) ]; end
    def rewrite_null(t); [ '_nul', nil, line_number(t) ]; end

    def rewrite_val(t); rewrite(t.c0); end

    def rewrite_arr(t)

      cn = t.subgather(nil).collect { |n| rewrite(n) }
      cn = 0 if cn.empty?

      [ '_arr', cn, ln(t) ]
    end

    def rewrite_obj(t)

      cn =
        t.subgather(nil).inject([]) do |a, tt|
          k = rewrite(tt.c0.c0)
          a << [ '_key', [ k ], k[2] ]
          a << rewrite(tt.c4)
        end
      cn = 0 if cn.empty?

      [ '_obj', cn, ln(t) ]
    end

    def rewrite_par(t)

      Line.new(t).to_a
    end

    def rewrite_exp(t)

      return rewrite(t.c0) if t.children.size == 1

      cn = [ rewrite(t.c0) ]
      op = t.lookup(:sop).string

      tcn = t.children[2..-1].dup

      loop do
        c = tcn.shift; break unless c
        cn << rewrite(c)
        o = tcn.shift; break unless o
        o = o.lookup(:sop).string
        next if o == op
        cn = [ [ op, cn, cn.first[2] ] ]
        op = o
      end

      [ op, cn, cn.first[2] ]
    end

    class Line

      attr_accessor :parent, :indent
      attr_reader :children

      def initialize(tree)

        @parent = nil
        @indent = -1
        @head = 'sequence'
        @children = []
        @line = 0

        read(tree) if tree
      end

      def append(line)

        if line.indent == ';'
          line.indent = self.indent + 2
        elsif line.indent.is_a?(String)
          line.indent = self.indent
        end

        if line.indent > self.indent
          @children << line
          line.parent = self
        else
          @parent.append(line)
        end
      end

      def to_a

        if @head.is_a?(Array) && @children.empty?
          @head
        else
          [ @head, @children.collect(&:to_a), @line ]
        end
      end

      protected

      def read(tree)

        if it = tree.lookup(:ind)
          semis = it.string.chars.inject(0) { |t, c| c == ';' ? t + 1 : t }
          @indent = semis > 0 ? ';' * semis : it.length
        end

        gt = tree.lookup(:grp)
        @line = Rad.line_number(gt)

        ht = gt.lookup(:hed)

        @head = Flor::Rad.rewrite(ht.c0)
        @head = @head[0] if @head[0].is_a?(String) && @head[1] == []

        @children.concat(
          gt.c1.gather(:elt).collect do |et|

            v = Flor::Rad.rewrite(et.lookup(:exp))

            if kt = et.lookup(:key)
              k = Flor::Rad.rewrite(kt.c0)
              [ '_att', [ k, v ], k[2] ]
            else
              [ '_att', [ v ], v[2] ]
            end
          end)
      end
    end

    def rewrite_radial(t)

      root = Line.new(nil)
      prev = root

      t.gather(:lin).each do |lt|
        l = Line.new(lt)
        prev.append(l)
        prev = l
      end

      return root.children.first.to_a if root.children.count == 1

      root.to_a
    end

    def parse(input, fname=nil, opts={})

      opts = fname if fname.is_a?(Hash) && opts.empty?

      #pp super(input, rewrite: false)
      #pp super(input, debug: 3)
      #pp super(input, debug: 2)

      r = super(input, opts)
      r << fname if fname

      r
    end
  end # module Rad

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

