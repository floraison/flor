# frozen_string_literal: true

require 'io/console'


module Flor

  class << self

    def to_djan(x, opts={})

      out = StringIO.new
      out.set_encoding('UTF-8')

      opts[:c] = Flor.colours(opts)

      if [ :console, true ].include?(opts[:width])
        opts[:width] = IO.console.winsize[1] rescue 80
      #elsif opts[:width].is_a?(Integer)
        # let it go
      elsif mw = (opts[:mw] || opts[:maxwidth] || opts[:max_width])
        opts[:width] = [ (IO.console.winsize[1] rescue 80), mw ].min
      end
      opts[:indent] ||= 0 if opts[:width]

      opts[:str_escape] ||= []

      Djan.to_d(x, out, opts)

      out.string
    end

    alias to_d to_djan

    # to_d, but without colours
    #
    def to_dnc(x)

      to_d(x, colours: false)
    end
  end

  module Djan
    extend self

    def to_d(x, out, opts)

      case x
      when nil then nil_to_d(x, out, opts)
      when String then string_to_d(x, out, opts)
      when Hash then object_to_d(x, out, opts)
      when Array then array_to_d(x, out, opts)
      when TrueClass then boolean_to_d(x.to_s, out, opts)
      when FalseClass then boolean_to_d(x.to_s, out, opts)
      else num_to_d(x.to_s, out, opts)
      end
    end

    def len(x, opts)

      opts = opts.merge(c: Flor.no_colours, indent: nil, width: nil)
      o = StringIO.new

      to_d(x, o, opts)

      o.string.length
    end

    def adjust(x, opts)

      i = opts[:indent]
      w = opts[:width]

      return opts unless i && w && (i + len(x, opts) < w)
      opts.merge(indent: nil)
    end

    def newline(out, opts)

      out << "\n"
    end

    def space(out, opts, force=false)

      out << ' ' if force || ! opts[:compact]
    end

    def newline_or_space(out, opts)

      if kt = opts[:keytab]
        out << ' ' * kt
        :indent
      elsif opts[:indent]
        newline(out, opts)
        :newline
      elsif ! opts[:compact]
        space(out, opts)
        :space
      end
    end

    def indent_space(out, opts)

      return if opts.delete(:first)
      i = opts[:indent]
      out << ' ' * i if i
    end

    def indent(opts, os={})

      if kt = os[:keytab]
        opts.merge(indent: nil, keytab: kt)
      elsif i = opts[:indent]
        opts.merge(indent: i + (os[:inc] || 1) * 2, first: os[:first])
      else
        opts
      end
    end

    def object_to_d(x, out, opts)

      inner = opts.delete(:inner)

      indent_space(out, opts)

      return c_inf('{}', out, opts) if x.empty?

      opts = adjust(x, opts)

      unless inner
        c_inf('{', out, opts); space(out, opts)
      end

      key_max_len =
        if opts[:compact]
          nil
        else
          i = opts[:indent]
          w = opts[:width]
            #
          kml, vml =
            x.inject([ 0, 0 ]) { |(kl, vl), (k, v)|
              [ [ kl, len(k.to_s, opts) ].max, [ vl, len(v, opts) ].max ] }
          kml += 1
            #
          if i && w && i + kml + 1 + vml < w
            kml
          else
            nil
          end
        end

      x.each_with_index do |(k, v), ii|

        kl = string_to_d(k, out, indent(opts, first: ii == 0))
        c_inf(':', out, opts)

        kt = key_max_len ? key_max_len - kl : nil
        r = newline_or_space(out, opts.merge(keytab: kt))

        to_d(v, out, indent(opts, inc: 2, keytab: r == :newline ? kt : 1))

        if ii < x.size - 1
          c_inf(',', out, opts)
          newline_or_space(out, opts)
        end
      end

      unless inner
        space(out, opts); c_inf('}', out, opts)
      end
    end

    def array_to_d(x, out, opts)

      inner = opts.delete(:inner)

      indent_space(out, opts)

      return c_inf('[]', out, opts) if x.empty?

      opts = adjust(x, opts)

      unless inner
        c_inf('[', out, opts); space(out, opts)
      end

      x.each_with_index do |e, i|
        to_d(e, out, indent(opts, first: i == 0))
        if i < x.size - 1
          c_inf(',', out, opts)
          newline_or_space(out, opts)
        end
      end

      unless inner
        space(out, opts); c_inf(']', out, opts)
      end
    end

    def string_to_d(x, out, opts)

      x = x.to_s

      indent_space(out, opts)

      if (
        opts[:json] ||
        x.match(/\A[^: \b\f\n\r\t"',()\[\]{}#\\+%\/><^!=-]+\z/) == nil ||
        x.to_i.to_s == x ||
        x.to_f.to_s == x ||
        opts[:str_escape].include?(x)
      ) then
        s = x.inspect
        c_str(s, out, opts)
        s.length
      else
        c_str(x, out, opts)
        x.length
      end
    end

    def boolean_to_d(x, out, opts)

      indent_space(out, opts); x ? c_tru(x, out, opts) : c_fal(x, out, opts)
    end

    def num_to_d(x, out, opts)

      indent_space(out, opts); c_num(x, out, opts)
    end

    def nil_to_d(x, out, opts)

      indent_space(out, opts); c_nil('null', out, opts)
    end

    def c_inf(s, out, opts); out << opts[:c].dark_gray(s); end

    def c_nil(s, out, opts); out << opts[:c].dark_gray(s); end
    def c_tru(s, out, opts); out << opts[:c].green(s); end
    def c_fal(s, out, opts); out << opts[:c].red(s); end
    #def c_str(s, out, opts); out << opts[:c].brown(s); end
    def c_str(s, out, opts)
      out << opts[:c].brown(s)
      #out << opts[:c].brown(s).tap { |x| p [ x, x.encoding ] }
      #out << opts[:c].brown(s).encode('UTF-8')
    end
    def c_num(s, out, opts); out << opts[:c].light_blue(s); end
  end
end

