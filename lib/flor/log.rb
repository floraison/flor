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

  def self.log_message(m, opts={})

    _rs, _dg, _yl, _bl, _lg = colours

    n =
      Time.now
    tm =
      if opts[:date]
        n.strftime('%Y%m%d.%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      else
        n.strftime('%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      end

    pt = "#{_bl}#{m['point'][0, 3]}#{_dg}"
    ni = m['nid'] ? "#{m['nid']} " : ''
    fr = m['from'] ? " from #{m['from']}" : ''

    rt = ret_to_s(m)
    rt = rt.length > 0 ? " #{_lg}f.ret #{rt}" : ''

    t = m['tree'];
    t0 = t ? " [#{_yl}#{Flor.s_to_d(t[0], compact: true)}#{_dg} L#{t[2]}]" : ''
    #t = t ? " #{t[1..-2].inspect[1..-2]}]" : ''

    cn = t ? ' ' + Flor.to_d(t[1], compact: true, inner: true) : ''
    cn = cn.length > 49 ? "#{cn[0, 49]}..." : cn

    #ind = '  ' * ni.split('_').size

    puts "  #{tm} #{_dg}#{ni}#{pt}#{t0}#{cn}#{fr}#{rt}#{_rs}"
  end

  class Colours

    class << self

      def reset; "[0;0m"; end

      def bright;      "[1m"; end
      def dim;         "[2m"; end
      def underlined;  "[4m"; end
      def blink;       "[5m"; end
      def reverse;     "[7m"; end
      def hidden;      "[8m"; end

      def default;        "[39m"; end
      def black;          "[30m"; end
      def red;            "[31m"; end
      def green;          "[32m"; end
      def yellow;         "[33m"; end
      def blue;           "[34m"; end
      def magenta;        "[35m"; end
      def cyan;           "[36m"; end
      def light_gray;     "[37m"; end

      def dark_gray;      "[90m"; end
      def light_red;      "[91m"; end
      def light_green;    "[92m"; end
      def light_yellow;   "[93m"; end
      def light_blue;     "[94m"; end
      def light_magenta;  "[95m"; end
      def light_cyan;     "[96m"; end
      def white;          "[97m"; end

      def bg_default;        "[49m"; end
      def bg_black;          "[40m"; end
      def bg_red;            "[41m"; end
      def bg_green;          "[42m"; end
      def bg_yellow;         "[43m"; end
      def bg_blue;           "[44m"; end
      def bg_magenta;        "[45m"; end
      def bg_cyan;           "[46m"; end
      def bg_light_gray;     "[47m"; end

      def bg_dark_gray;      "[100m"; end
      def bg_light_red;      "[101m"; end
      def bg_light_green;    "[102m"; end
      def bg_light_yellow;   "[103m"; end
      def bg_light_blue;     "[104m"; end
      def bg_light_magenta;  "[105m"; end
      def bg_light_cyan;     "[106m"; end
      def bg_white;          "[107m"; end

      alias brown yellow
      alias purple magenta
      alias dark_grey dark_gray
      alias light_grey light_gray

      alias rs reset
      alias ba black
      alias bk black
      alias bu blue
      alias rd red
      alias gn green
      alias gy light_gray
      alias yl yellow
      alias br bright
      alias un underlined
      alias rv reverse
      alias bn blink
    end

    def self.set(names)

      names.collect { |n| self.send(n) }
    end

    def self.method_missing(m, *args)

      return super if args.length != 0
      m = m.to_s
      return tty($stdout, m) if m.match(/\Atty_/)
      return tty($stderr, m) if m.match(/\Aetty_/)

      super
    end

    def self.tty(target, m)

      target.tty? ? self.send(m.split('_', 2)[-1]) : ''
    end
  end

  COLSET = Colours.set(%w[ reset dark_grey light_yellow blue light_grey ])
  NO_COLSET = [ '' ] * COLSET.length

  # return reset, dark grey, yellow, blue, light grey
  #
  def self.colours(opts={ color: true })

    (opts[:color] || opts[:colour]) && $stdout.tty? ? COLSET : NO_COLSET
  end

  def self.print_tree(tree, nid='0', opts={ color: true })

    _rs, _dg, _yl = colours(opts)

    h = "#{_yl}#{Flor.s_to_d(tree[0], compact: true)}"
    c = tree[1].is_a?(Array) ? '' : " #{_yl}#{tree[1]}"
    l = " #{_dg}L#{tree[2]}"

    puts "#{_dg}+" if nid == '0'
    puts "#{_dg}| #{nid} #{h}#{c}#{l}#{_rs}"
    if tree[1].is_a?(Array)
      tree[1].each_with_index { |ct, i| print_tree(ct, "#{nid}_#{i}", opts) }
    end
    puts "#{_dg}+#{_rs}" if nid == '0'
  end

  def self.ret_to_s(m)

    ret = (m['payload'] || {})['ret']
    s = Flor.to_d(ret, compact: true)
    l = s.length
    l < 35 ? s : "#{s[0, 35]}(...L#{l})"
  end
end

