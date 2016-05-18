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

  # return reset, dark grey, yellow, blue, light grey
  #
  def self.colours(opts={ color: true })

    opts[:color] && $stdout.tty? ?
    [ "[0;0m", "[1;30m", "[1;33m", "[1;34m", "[0;37m" ] :
    [ '', '', '', '', '' ]
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

  def self.print_src(tree, opts={ color: true })

    _rs, _dg, _, _, _lg = colours(opts)

    s =
      if tree.is_a?(String)
        tree
      else
        StringIO.new.tap { |o| PP.pp(tree, o, 77) }.string
      end
    ss = s.split("\n")
    ind =
      ss.inject(9999) { |i, l|
        m = l.match(/\A(\s+)/)
        ii = (m && m[1].length) || 9999
        ii < i ? ii : i
      }
    ss.each_with_index do |l, i|
      next if l.strip.length < 1
      puts "#{_dg}L#{'%03d' % (i + 1)} #{_lg}#{l[ind..-1]}#{_rs}"
    end
  end

  def self.ret_to_s(m)

    ret = (m['payload'] || {})['ret']
    s = Flor.to_d(ret, compact: true)
    l = s.length
    l < 35 ? s : "#{s[0, 35]}(...L#{l})"
  end
end

