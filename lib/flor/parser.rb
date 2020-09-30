# frozen_string_literal: true
module Flor

  def self.parse(input, fname=nil, opts={})

#Raabro.pp(Flor::Parser.parse(input, debug: 2), colours: true)
#Raabro.pp(Flor::Parser.parse(input, debug: 3), colours: true)
    opts = fname if fname.is_a?(Hash) && opts.empty?

    if r = Flor::Parser.parse(input, opts)
      r << fname if fname
      r
    else
      r = Flor::Parser.parse(input, opts.merge(error: true))
      fail Flor::ParseError.new(r, fname)
    end
  end

  class ParseError < StandardError

    attr_reader :line, :column, :offset, :msg, :visual, :fname

    def initialize(error_array, fname)

#puts "-" * 80; p error_array; puts error_array.last; puts "-" * 80
      @line, @column, @offset, @msg, @visual = error_array
      @fname = fname

      m = "syntax error at line #{@line} column #{@column}"
      m += " in #{fname}" if fname

      super(m)
    end
  end

  module Parser include Raabro

    # parsing

    def wstar(i); rex(nil, i, /[ \t]*/); end
    def wplus(i); rex(nil, i, /[ \t]+/); end

    def rnstar(i); rex(nil, i, /[\r\n]*/); end
    def rnplus(i); rex(nil, i, /[\r\n]+/); end

    def dot(i); str(nil, i, '.'); end
    def colon(i); str(nil, i, ':'); end
    def semicolon(i); str(nil, i, ';'); end
    def comma(i); str(nil, i, ','); end
    def dquote(i); str(nil, i, '"'); end
    def slash(i); str(nil, i, '/'); end
    def dollar(i); str(nil, i, '$'); end
    def pipepipe(i); str(nil, i, '||'); end

    def pstart(i); str(nil, i, '('); end
    def pend(i); str(nil, i, ')'); end
    def sbstart(i); str(nil, i, '['); end
    def sbend(i); str(nil, i, ']'); end
    def pbstart(i); str(nil, i, '{'); end
    def pbend(i); str(nil, i, '}'); end

    def null(i); str(:null, i, 'null'); end

    def number(i)
      rex(:number, i, /[-+]?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?/)
    end

    def tru(i); str(nil, i, 'true'); end
    def fls(i); str(nil, i, 'false'); end
    def boolean(i); alt(:boolean, i, :tru, :fls); end

    def colon_eol(i); seq(:colo, i, :colon, :eol); end
    def semicolon_eol(i); seq(nil, i, :semicolon, :eol); end
      #
    def rf_slice(i)
      seq(:refsl, i, :exp, :comma_qmark_eol, :exp)
    end
    def colon_exp(i)
      seq(nil, i, :colon_eol, :exp_qmark)
    end
    def rf_steps(i)
      seq(:refst, i, :exp_qmark, :colon_exp, :colon_exp, '?')
    end
    def rf_sqa_index(i)
      alt(nil, i, :rf_slice, :rf_steps, :exp)
    end
    def rf_sqa_semico_index(i)
      seq(nil, i, :semicolon_eol, :rf_sqa_index)
    end
    def rf_sqa_idx(i)
      seq(:refsq, i, :sbstart, :rf_sqa_index, :rf_sqa_semico_index, '*', :sbend)
    end
    def rf_dot_idx(i)
      seq(nil, i, :dot, :rf_symbol)
    end
    def rf_index(i); alt(nil, i, :rf_dot_idx, :rf_sqa_idx); end
    def rf_symbol(i); rex(:refsym, i, /[^.:;| \b\f\n\r\t"',()\[\]{}#\\]+/); end
      #
    def reference(i); seq(:ref, i, :rf_symbol, :rf_index, '*'); end

    def dqsc(i)
      rex(:dqsc, i, %r{
        (
          \\["\\\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          \$(?!\() |
          [^\$"\\\b\f\n\r\t]
        )+
      }x)
    end

    def rxoc(i); rex(:rxoc, i, /[imxouesn]/); end

    def rxsc(i)
      rex(:rxsc, i, %r{
        (
          \\[\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          \$(?!\() |
          [^\$/\b\f\n\r\t]
        )+
      }x)
    end

    def dor_lines(i)
      seq(:dpar_lines, i, :pipepipe, :eol_wstar, :line, '+')
    end
    def dpar_lines(i)
      seq(:dpar_lines, i, :eol_wstar, :line, '+')
    end

    def dpar(i)
      seq(
        :dpar, i,
        :dollar, :pstart, :dpar_lines, :dor_lines, '?', :eol_wstar, :pend)
    end

    def dpar_or_rxoc(i); alt(nil, i, :dpar, :rxoc); end

    def rxopts(i); rep(:rxopts, i, :dpar_or_rxoc, 0); end

    def dpar_or_dqsc(i); alt(nil, i, :dpar, :dqsc); end
    def dpar_or_rxsc(i); alt(nil, i, :dpar, :rxsc); end

    def dqstring(i)
      seq(:dqstring, i, :dquote, :dpar_or_dqsc, '*', :dquote)
    end

    def rxr(i) # used to break ambiguity against / (infix division)
      rex(nil, i, /(regex|rex|rx|re|r)/)
    end

    def rxstring(i)
      seq(:rxstring, i, :rxr, '?', :slash, :dpar_or_rxsc, '*', :slash, :rxopts)
    end

    def sqstring(i)
      rex(:sqstring, i, %r{
        '(
          \\['\\\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*'
      }x)
    end

    def comment(i); rex(nil, i, /#[^\r\n]*/); end

    def eol(i); seq(nil, i, :wstar, :comment, '?', :rnstar); end
    def eol_wstar(i); seq(nil, i, :wstar, :comment, '?', :rnstar, :wstar); end
    def eol_plus(i); seq(nil, i, :wstar, :comment, '?', :rnplus); end
    def postval(i); rep(nil, i, :eol, 0); end

    def comma_eol(i); seq(nil, i, :comma, :eol, :wstar); end
    def sep(i); alt(nil, i, :comma_eol, :wstar); end

    def comma_qmark_eol(i); seq(nil, i, :comma, '?', :eol); end
    def coll_sep(i); alt(nil, i, :comma_qmark_eol, :wstar); end

    def woreol(i); alt(:woreol, i, :wplus, :eol_plus); end

    def ent(i)
      seq(:ent, i, :key, :postval, :colon, :postval, :exp, :postval)
    end
    def ent_qmark(i)
      rep(nil, i, :ent, 0, 1)
    end

    def exp_qmark(i); rep(nil, i, :exp, 0, 1); end

    def obj(i); eseq(:obj, i, :pbstart, :ent_qmark, :coll_sep, :pbend); end
    def arr(i); eseq(:arr, i, :sbstart, :exp_qmark, :coll_sep, :sbend); end

    def par(i)
      seq(:par, i, :pstart, :eol_wstar, :node, :eol_wstar, :pend)
    end

    def val(i)
      altg(:val, i,
        :panode, :par,
        :reference, :sqstring, :dqstring, :rxstring,
        :arr, :obj,
        :number, :boolean, :null)
    end
    def val_ws(i); seq(nil, i, :val, :wstar); end

    # precedence
    #  %w[ or or ], %w[ and and ],
    #  %w[ equ == != <> ], %w[ lgt < > <= >= ], %w[ sum + - ], %w[ prd * / % ],

    def ssmod(i); str(:sop, i, /%/); end
    def ssprd(i); rex(:sop, i, /[\*\/]/); end
    def sssum(i); rex(:sop, i, /[+-]/); end
    def sslgt(i); rex(:sop, i, /(<=?|>=?)/); end
    def ssequ(i); rex(:sop, i, /(==?|!=|<>)/); end
    def ssand(i); str(:sop, i, 'and'); end
    def ssor(i); str(:sop, i, 'or'); end

    def smod(i); seq(nil, i, :ssmod, :eol, '?'); end
    def sprd(i); seq(nil, i, :ssprd, :eol, '?'); end
    def ssum(i); seq(nil, i, :sssum, :eol, '?'); end
    def slgt(i); seq(nil, i, :sslgt, :eol, '?'); end
    def sequ(i); seq(nil, i, :ssequ, :eol, '?'); end
    def sand(i); seq(nil, i, :ssand, :woreol); end # space or eol
    def sor(i); seq(nil, i, :ssor, :woreol); end # space or eol

    def emod(i); jseq(:exp, i, :val_ws, :smod); end
    def eprd(i); jseq(:exp, i, :emod, :sprd); end
    def esum(i); jseq(:exp, i, :eprd, :ssum); end
    def elgt(i); jseq(:exp, i, :esum, :slgt); end
    def eequ(i); jseq(:exp, i, :elgt, :sequ); end
    def eand(i); jseq(:exp, i, :eequ, :sand); end
    def eor(i); jseq(:exp, i, :eand, :sor); end

    alias exp eor

    def key(i); seq(:key, i, :exp); end
    def keycol(i); seq(nil, i, :key, :wstar, :colon, :eol_wstar); end

    def att(i); seq(:att, i, :sep, :keycol, '?', :exp); end
    def riou(i); rex(:iou, i, /(if|unless)/); end
    def iou(i); seq(nil, i, :sep, :riou); end # If Or Unless
    def natt(i); alt(nil, i, :iou, :att); end

    def head(i); seq(:head, i, :exp); end
    def indent(i); rex(:indent, i, /[ \t]*/); end
    def node(i); seq(:node, i, :indent, :head, :natt, '*'); end

    def linjoin(i); rex(nil, i, /[ \t]*(\\|\|(?!\|)|;)[ \t]*/); end
    def outjnl(i); seq(nil, i, :linjoin, :comment, '?', :rnstar); end
    def outnlj(i); seq(nil, i, :wstar, :comment, '?', :rnstar, :linjoin); end
    def outdent(i); alt(:outdent, i, :outjnl, :outnlj, :eol); end

    def line(i)
      seq(:line, i, :node, '?', :outdent)
    end
    def panode(i)
      seq(:panode, i, :pstart, :eol_wstar, :line, '*', :eol, :pend)
    end

    def flor(i); rep(:flor, i, :line, 0); end

    # rewriting

    def line_number(t)

      t.input.string[0..t.offset].scan("\n").count + 1
    end
    alias ln line_number

    def rewrite_par(t)

      Nod.new(t.lookup(:node), nil).to_a
    end

    def rewrite_node(t)

      Nod.new(t, nil).to_a
    end

    def rewrite_ref(t)

      tts = t.subgather(nil)

      if tts.length == 1
        tt = tts.first
        [ tt.string, [], ln(tt) ]
      else
        [ '_ref', tts.collect { |ct| rewrite(ct) }, ln(t) ]
      end
    end

    def rewrite_refsym(t)

      s = t.string

      if s.match(/\A\d+\z/)
        [ '_num', s.to_i, ln(t) ]
      else
        [ '_sqs', s, ln(t) ]
      end
    end

    def rewrite_refsq(t)

      tts = t.subgather(nil)

      if tts.length == 1
        rewrite(tts.first)
      else
        [ '_arr', tts.collect { |tt| rewrite(tt) }, ln(t) ]
      end
    end

    def rewrite_refsl(t)

      st, co = t.subgather(nil)

      [ '_obj', [
        [ '_sqs', 'start', ln(st) ], rewrite(st),
        [ '_sqs', 'count', ln(co) ], rewrite(co),
      ], ln(t) ]
    end

    def rewrite_refst(t)

#puts "-" * 80
#Raabro.pp(t, colours: true)
      ts = t.subgather(nil).collect { |tt| tt.name == :colo ? ':' : tt }
      ts.unshift(0) if ts.first == ':'                 # begin
      ts.push(':') if ts.count { |ct| ct == ':' } < 2  #
      ts.push(1) if ts.last == ':'                     # step
      ts.insert(2, -1) if ts[2] == ':'                 # end

      be, _, en, _, st = ts
      be = be.is_a?(Integer) ? [ '_num', be, ln(t) ] : rewrite(be)
      en = en.is_a?(Integer) ? [ '_num', en, ln(t) ] : rewrite(en)
      st = st.is_a?(Integer) ? [ '_num', st, ln(t) ] : rewrite(st)

      [ '_obj', [
        [ '_sqs', 'start', be[2] ], be,
        [ '_sqs', 'end', en[2] ], en,
        [ '_sqs', 'step', st[2] ], st,
      ], ln(t) ]
    end

    UNESCAPE = {
      "'" => "'", '"' => '"', '\\' => '\\', '/' => '/',
      'b' => "\b", 'f' => "\f", 'n' => "\n", 'r' => "\r", 't' => "\t"
    }
    def restring(s)
      s.gsub(
        /\\(?:(['"\\\/bfnrt])|u([\da-fA-F]{4}))/
      ) {
        $1 ? UNESCAPE[$1] : [ "#$2".hex ].pack('U*')
      }
    end

    def rewrite_dqsc(t); [ '_sqs', restring(t.string), ln(t) ]; end
    alias rewrite_rxsc rewrite_dqsc

    def rewrite_dpar_lines(t)

#Raabro.pp(t, colours: true); p t.string
      [ '_dmute', t.subgather(:node).collect { |ct| rewrite(ct) }, ln(t) ]
    end

    def rewrite_dpar(t)

      [ '_dol', t.subgather(nil).collect { |ct| rewrite(ct) }, ln(t) ]
    end

    def rewrite_dqstring(t)

      cn = t.subgather(nil).collect { |tt| rewrite(tt) }

      if cn.size == 1 && cn[0][0] == '_sqs'
        cn[0]
      elsif cn.size == 0
        [ '_sqs', '', ln(t) ]
      else
        [ '_dqs', cn, ln(t) ]
      end
    end

    alias rewrite_rxopts rewrite_dqstring

    def rewrite_rxoc(t); [ '_sqs', t.string, ln(t) ]; end

    def rewrite_rxstring(t)

      l = ln(t)
      cts = t.subgather(nil)
      rot = cts.pop

      cn = cts.collect(&method(:rewrite))

      cn.unshift([ '_att', [ [ 'rxopts', [], l ], rewrite(rot) ], l ]) \
        if rot.length > 0

      [ '_rxs', cn, l ]
    end

    def rewrite_sqstring(t); [ '_sqs', restring(t.string[1..-2]), ln(t) ]; end
    def rewrite_boolean(t); [ '_boo', t.string == 'true', line_number(t) ]; end
    def rewrite_null(t); [ '_nul', nil, line_number(t) ]; end

    def rewrite_number(t)

      s = t.string; [ '_num', s.index('.') ? s.to_f : s.to_i, ln(t) ]
    end

    def rewrite_obj(t)

      l = ln(t)

      cn =
        t.subgather(nil).inject([]) do |a, tt|
          a << rewrite(tt.c0.c0)
          a << rewrite(tt.c4)
        end
      cn = [ [ '_att', [ [ '_', [], l ] ], l ] ] if cn.empty?

      [ '_obj', cn, l ]
    end

    def rewrite_arr(t)

      l = ln(t)

      cn = t.subgather(nil).collect { |n| rewrite(n) }
      cn = [ [ '_att', [ [ '_', [], l ] ], l ] ] if cn.empty?

      [ '_arr', cn, l ]
    end

    def rewrite_val(t)

      rewrite(t.c0)
    end

    def invert(operation, operand)

      l = operand[2]

      case operation
      when '+'
        if operand[0] == '_num' && operand[1].is_a?(Numeric)
          [ operand[0], - operand[1], l ]
        else
          [ '-', [ operand ], l ]
        end
      when '*'
        [ '/', [ [ 'num', 1, l ], operand ], l ]
      else
fail "don't know how to invert #{operation.inspect}" # FIXME
      end
    end

    def rewrite_exp(t)

#puts "-" * 80
#puts caller[0, 7]
#Raabro.pp(t, colours: true)
      return rewrite(t.c0) if t.children.size == 1
#puts "-" * 80
#puts caller[0, 7]
#Raabro.pp(t, colours: true)

      cn = t.children.collect { |ct| ct.lookup(nil) }

      operation = cn.find { |ct| ct.name == :sop }.string

      operator = operation
      operands = []

      cn.each do |ct|
        if ct.name == :sop
          operator = ct.string
        else
          o = rewrite(ct)
          o = invert(operation, o) if operator != operation
          operands << o
        end
      end

      [ operation, operands, operands.first[2] ]
    end

    class Nod

      attr_accessor :parent, :indent
      attr_reader :type, :children

      def initialize(tree, outdent)

        @parent = nil
        @indent = -1
        @head = 'sequence'
        @children = []
        @line = 0

        @outdent = outdent ? outdent.strip : nil
        @outdent = nil if @outdent && @outdent.size < 1

        read(tree) if tree
      end

      def append(node)

        if @outdent
          if @outdent.index('\\')
            node.indent = self.indent + 2
          elsif @outdent.index('|') || @outdent.index(';')
            node.indent = self.indent
          end
          @outdent = nil
        end

        if node.indent > self.indent
          @children << node
          node.parent = self
        else
          @parent.append(node)
        end
      end

      def to_a

        return [ @head, @children, @line ] unless @children.is_a?(Array)
        return @head if @head.is_a?(Array) && @children.empty?

        cn = @children.collect(&:to_a)

        as, non_atts = cn.partition { |c| c[0] == '_att' }
        atts, suff = [], nil

        as.each do |c|

          if %w[ if unless ].include?(c[1])
            suff = []
          elsif suff && c[1].length > 1
            iou = suff.shift; iou[1] = [ [ iou[1], [], iou[2] ] ]
            atts << iou
            atts.concat(suff)
            suff = nil
          end

          (suff || atts) << c
        end

        atts, non_atts = ta_rework_arr_or_obj(atts, non_atts)

        core = [ @head, atts + non_atts, @line ]
        core = core[0] if core[0].is_a?(Array) && core[1].empty?
        core = ta_rework_core(core) if core[0].is_a?(Array)

        return core unless suff

        ta_rework_suff(core, suff)
      end

      protected

      def ta_rework_suff(core, suff)

        cond = suff[1][1][0]
        suff[2..-1].each { |ct| cond[1] << ct }

        [ '_' + suff.shift[1], [ cond, core ], @line ]
      end

      def ta_rework_arr_or_obj(atts, non_atts)

        return [ atts, non_atts ] unless (
          @head.is_a?(Array) &&
          non_atts.empty? &&
          %w[ _arr _obj ].include?(@head[0]))

        cn = @head[1] + atts + non_atts
        @head = @head[0]

        cn.partition { |c| c[0] == '_att' }
      end

      def ta_rework_core(core)

        hd, cn, ln = core
        s = @tree.lookup(:head).string.strip

        [ '_head', [
          [ '_sqs', s, ln ],
          hd,
          [ '__head', cn, ln ]
        ], ln ]
      end

      def read(tree)

        @tree = tree
#puts "-" * 80
#Raabro.pp(tree, colours: true)

        @indent = tree.lookup(:indent).string.length

        ht = tree.lookup(:head)
        @line = Flor::Parser.line_number(ht)

        @head = Flor::Parser.rewrite(ht.c0)
        @head = @head[0] if @head[0].is_a?(String) && @head[1] == []

        atts = tree.children[2..-1]
          .inject([]) { |as, ct|

            ct = ct.lookup(nil)

            if ct.name == :iou

              as.push([ '_att', ct.string, @line ])

            else

              kt = ct.children.size == 3 ? ct.children[1].lookup(:key) : nil
              v = Flor::Parser.rewrite(ct.clast)

              if kt
                k = Flor::Parser.rewrite(kt.c0)
                as.push([ '_att', [ k, v ], k[2] ])
              else
                as.push([ '_att', [ v ], v[2] ])
              end
            end }

        @children.concat(atts)

        rework_subtraction if @head == '-'
        rework_addition if @head == '+' || @head == '-'
      end

      def rework_subtraction

        return unless @children.size == 1

        c = @children.first
        return unless c[0] == '_att' && c[1].size == 1

        c = c[1].first

        if c[0] == '_num'
          @head = '_num'
          @children = - c[1]
        elsif %w[ - + ].include?(c[0])
          @head = c[0]
          @children = c[1]
          @children[0] = Flor::Parser.invert('+', @children[0])
        end
      end

      def rework_addition

        katts, atts, children = @children
          .inject([ [], [], [] ]) { |cn, ct|
            if ct[0] == '_att'
              cn[ct[1].size == 2 ? 0 : 1] << ct
            else
              cn[2] << ct
            end
            cn }

        @children =
          katts + atts.collect { |ct| ct[1].first } + children
      end
    end

    def rewrite_flor(t)

      prev = root = Nod.new(nil, nil)

      t.gather(:line).each do |lt|
        nt = lt.lookup(:node); next unless nt
        ot = lt.children.last.string
        n = Nod.new(nt, ot)
        prev.append(n)
        prev = n
      end

      root.children.count == 1 ? root.children.first.to_a : root.to_a
    end
    alias rewrite_panode rewrite_flor
  end # module Parser

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
