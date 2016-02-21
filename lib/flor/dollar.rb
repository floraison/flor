
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

  class Dollar

    module Parser include Raabro

#static fabr_tree *_str(fabr_input *i)
#{
#  return fabr_rex("s", i,
#    "("
#      "\\\\\\)" "|"
#      "[^\\$\\)]" "|"
#      "\\$[^\\(]"
#    ")+");
#}
      def istr(i)
        rex(:str, i, %r{
          ( \\\) | [^\$)] | \$[^(] )+
        }x)
      end

#static fabr_tree *_outerstr(fabr_input *i)
#{
#  return fabr_rex("s", i,
#    "("
#      "[^\\$]" "|" // doesn't mind ")"
#      "\\$[^\\(]"
#    ")+");
#}
      def ostr(i)
        rex(:str, i, %r{
          ( [^\$] | \$[^(] )+
        }x)
      end

      def pe(i); str(nil, i, ')'); end
      def dois(i); alt(nil, i, :dollar, :istr); end
      def span(i); rep(:span, i, :dois, 0); end
      def dps(i); str(nil, i, '$('); end
      def dollar(i); seq(:dollar, i, :dps, :span, :pe); end
      def doos(i); alt(nil, i, :dollar, :ostr); end
      def outer(i); rep(:span, i, :doos, 0); end

      def rewrite_str(t)
        t.string
      end
      def rewrite_dollar(t)
        cn = rewrite(t.children[1])
        c = cn.first
        if cn.size == 1 && c.is_a?(String)
          [ :dol, c ]
        else
          [ :dol, cn ]
        end
      end
      def rewrite_span(t)
        t.children.collect { |c| rewrite(c) }
      end
    end

    module PipeParser include Raabro

      def elt(i); rex(:elt, i, /[^|]+/); end
      def pipe(i); rex(:pipe, i, /\|\|?/); end
      def elts(i); jseq(:elts, i, :elt, :pipe); end

      def rewrite_elt(t); t.string; end
      def rewrite_pipe(t); t.string == '|' ? :pipe : :dpipe; end
      def rewrite_elts(t); t.children.collect { |e| rewrite(e) }; end
    end

    #def lookup(s)
    #  # ...
    #end

    def quote(s, force)

      return s if force == false && s[0, 1] == '"' && s[-1, 1] == '"'

      JSON.dump([ s ])[1..-2]
    end

    def lfilter(s, cmp, len)

      l = s.length

      case cmp
        when '>' then l > len
        when '>=' then l >= len
        when '<' then l < len
        when '<=' then l <= len
        when '=', '==' then l == len
        when '!=', '<>' then l != len
        else false
      end
    end

    def call(fun, s)

      case fun
        when 'u' then s.upcase
        when 'd' then s.downcase
        when 'r' then s.reverse
        when 'c' then s.capitalize.gsub(/\s[a-z]/) { |c| c.upcase }
        when 'q' then quote(s, false)
        when 'Q' then quote(s, true)

        when /\A-?\d+\z/ then s[fun.to_i]
        when /\A(-?\d+), *(-?\d+)\z/ then s[$1.to_i, $2.to_i]
        when /\A(-?\d+)\.\.(-?\d+)\z/ then s[$1.to_i..$2.to_i]

        when /\A\s*l\s*([><=!]=?|<>)\s*(\d+)\z/
          lfilter(s, $1, $2.to_i) ? s : nil

        else s
      end
    end

    def unescape(s)

      s.gsub(/\\[\$)]/) { |m| m[1, 1] }
    end

    def do_eval(t)

      #return t if t.is_a?(String)
      return unescape(t) if t.is_a?(String)

      return t.collect { |c| do_eval(c) }.join if t[0] != :dol

      k = do_eval(t[1])
      ks = PipeParser.parse(k)

      result = nil
      mode = :lookup # vs :call

      ks.each do |k|

        if k == :pipe then mode = :call; next; end
        if k == :dpipe && result then break; end
        if k == :dpipe then mode = :lookup; next; end

        result =
          if mode == :lookup
            k[0, 1] == "'" ? k[1..-1] : lookup(k)
          else # :call
            call(k, result)
          end
      end

      result
    end

    def expand(s)

      return s unless s.index('$')

      t = Parser.parse(s)
      t = t.first if t.size == 1

      do_eval(t)
    end
  end
end

