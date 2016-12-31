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

  def self.log_message(executor, m, opts={})

    _rs, _dg, _yl, _bl, _lg, _gr, _lr, _rd, _ma = colours(opts)
    _bri, _dim, _und, _, _rev, _ = colmods(opts)

    nid = m['nid']
    nd = executor.node(nid)

    a = [ '  ' ]

    n =
      Time.now
    tm =
      if opts[:date]
        n.strftime('%Y%m%d.%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      else
        n.strftime('%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      end
    a << tm
    a << ' '
    a << _dg

    if ex = (m['exid'] || '').split('.').last
      a << ex[-2..-1]
      a << ' '
    end

    a << "#{nd ? _dg : _dim + _dg}#{nid}#{_rs}#{_dg} " if nid

    pt = m['point'][0, 3]
    _pt =
      case pt
        when 'tri', 'sig' then _gr
        when 'cea', 'ter' then _lg
        when 'can' then _ma
        else _bl
      end
    a << "#{_pt}#{pt}#{_dg}"

    fla = m['flavour']
    a << " #{_lg}#{fla}#{_dg}" if fla

    sta = nd && nd['status']
    a << " #{_dim}#{_lg}#{(sta[0] || '')[0, 3]}:#{(sta[1] || '')[0, 3]}:#{sta[2]}#{_rs}#{_dg}" if sta

    t =
      m['tree']
    nt =
      t || Node.new(executor, nd, m).lookup_tree(nid)
    t0 =
      if t
        " [#{_yl}#{Flor.s_to_d(t[0], compact: true)}#{_dg} L#{t[2]}]"
      elsif nt
        " [#{_dg}#{Flor.s_to_d(nt[0], compact: true)}#{_dg} L#{nt[2]}]"
      else
        ''
      end
    a << t0

    oe = m['on_error'] ? " #{_rd}on_error" : ''
    a << oe

    tmi = m['timer_id']
    tmi = tmi ? " #{_dg}tmi:#{tmi}" : ''
    a << tmi
      #
    tri = m['trap_id']
    tri = tri ? " #{_dg}tri:#{tri}" : ''
    a << tri

    cn = t ? " #{_dg}#{Flor.to_d(t[1], compact: true, inner: true)}" : ''
    cn = cn.length > 49 ? "#{cn[0, 49]}..." : cn
    a << cn

    hp = nd && nd['heap']
    hp = hp && (hp != (t || [])[0]) ? " #{_dg}hp:#{nd['heap']}" : ''
    a << hp

    msr = " #{_dg}m#{m['m']}s#{m['sm'] || '_'}"
    msr << "r#{m['er']}>#{m['pr']}" if m['er'] && m['er'] > -1
    a << msr

    fr = m['from'] ? " from #{m['from']}" : ''
    a << fr

    rt = ret_to_s(executor, m)
    rt = rt.length > 0 ? " #{_lg}f.ret #{rt}" : ''
    a << rt

    ta =
      m['point'] == 'entered' || m['point'] == 'left' ?
      " #{_dg}tags:#{_gr}#{m['tags'].join(',')}" :
      nil
    a << ta

    vs =
      (nd && nd['vars']) ?
      " #{_dg}vars:#{_gr}#{nd['vars'].keys.join("#{_dg},#{_gr}")}" :
      ''
    a << vs

    %w[ fpoint dbg ].each do |k|
      a << " #{_dg}#{k}:#{m[k]}" if m.has_key?(k)
    end

    a << _rs

    puts a.join
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

  COLSET = Colours.set(%w[
    reset
    dark_grey light_yellow blue light_grey light_green light_red red magenta
  ])
  NO_COLSET = [ '' ] * COLSET.length
  MODSET = Colours.set(%w[
    bright dim underlined blink reverse hidden
  ])
  NO_MODSET = [ '' ] * MODSET.length

  def self.colours(opts={})

    opts[:colour] = true unless opts.has_key?(:color) || opts.has_key?(:colour)

    (opts[:color] || opts[:colour]) && $stdout.tty? ? COLSET : NO_COLSET
  end

  def self.colmods(opts={})

    opts[:colour] = true unless opts.has_key?(:color) || opts.has_key?(:colour)

    (opts[:color] || opts[:colour]) && $stdout.tty? ? MODSET : NO_MODSET
  end

  def self.print_src(src, opts={})

    _rs, _dg, _yl = colours(opts)

    puts "#{_dg}+---#{_rs}"

    puts "#{_dg}| #{opts.inspect}#{_rs}" if opts.any?

    if src.is_a?(String)
      src.split("\n").select { |l| l.strip.length > 0 }.each do |line|
        puts "#{_dg}| #{_yl}#{line}#{_rs}"
      end
    else
      ss = Flor.to_pretty_s(src).split("\n")
      ss.each do |line|
        puts "#{_dg}| #{_yl}#{line}#{_rs}"
      end
    end

    puts "#{_dg}.#{_rs}"
  end

  def self.print_tree(tree, nid='0', opts={})

#pp tree if nid == '0'
    headers = opts[:headers]; headers = true if headers.nil?

    _rs, _dg, _yl = colours(opts)

    h = "#{_yl}#{Flor.s_to_d(tree[0], compact: true)}"
    c = tree[1].is_a?(Array) ? '' : " #{_yl}#{tree[1]}"
    l = " #{_dg}L#{tree[2]}"

    puts "#{_dg}+---#{_rs}" if headers && nid == '0'
    puts "#{_dg}| #{nid} #{h}#{c}#{l}#{_rs}"
    if tree[1].is_a?(Array)
      tree[1].each_with_index { |ct, i| print_tree(ct, "#{nid}_#{i}", opts) }
    end
    puts "#{_dg}.#{_rs}" if headers && nid == '0'
  end

  def self.ret_to_s(executor, m)

    ret = (m['payload'] || {})['ret']
    s = Flor.to_d(ret, compact: true)
    l = s.length
    l < 35 ? s : "#{s[0, 35]}(...L#{l})"
  end

  def self.node_to_s(executor, n, opts, here=false)

    _rs, _dg, _yl, _bl, _gy, _gn, _rd = colours(opts)

    t = n['tree'] || Node.new(executor, n, nil).lookup_tree(n['nid'])
    t = Flor.to_d(t, compact: true) if t
    t = t[0, 35] + '...' if t && t.length > 35

    h = {}
    %w[ parent cnid noreply dbg removed ].each do |k|
      h[k] = n[k] if n.has_key?(k)
    end

    dbg = n['dbg'] ? "dbg:#{n['dbg']}" : nil
    nr = n.has_key?('noreply') ? "nr:#{n['noreply']}" : nil
    h = h.collect { |k, v| "#{k}:#{v}" }.join(' ')

    vs = n['vars']
    vs = 'vars:' + vs.keys.join(',') if vs
    ts = n['tags']
    ts = 'tags:' + ts.join(',') if ts

    flr = n['failure'] ? "#{_rd}flre" : ''

    here = here ? "#{_dg}<---msg['nid']" : nil

    [ _yl + n['nid'], t, h, ts, vs, flr, here ].compact.join(' ')
  end

  def self.ncns_to_s(executor, ncn, msg, opts, sio, ind, seen)

    n, cn = ncn
    nid = n['nid']

    return if seen.include?(nid)
    seen << nid

    sio.print(ind)
    sio.print(node_to_s(executor, n, opts, nid == msg['nid']))
    sio.print("\n")
    cn.each { |c| ncns_to_s(executor, c, msg, opts, sio, ind + ' ', seen) }
  end

  def self.nodes_to_s(executor, msg, opts)

    nodes = executor.execution['nodes'].values

    nodes = nodes.inject({}) { |h, n| h[n['nid']] = [ n, [] ]; h }
    nodes.values.each { |ncn|
      pa = ncn.first['parent']; next unless pa
      pan, pacn = nodes[pa]
      pacn << ncn if pacn
    }

    sio = StringIO.new
    seen = []
    nodes.values.each do |ncn|
      ncns_to_s(executor, ncn, msg, opts, sio, ' ', seen)
    end

    sio.string
  end

  def self.detail_msg(executor, m, opts={})

    return if m['_detail_msg_flag']
    m['_detail_msg_flag'] = true if opts[:flag]

    _rs, _dg, _yl = colours(opts)

    nid = m['nid']
    n = executor.execution['nodes'][nid]
    node = n ? Flor::Node.new(executor, n, m) : nil

    puts "#{_dg}<Flor.detail_msg>#{_rs}"
    print "#{_yl}"
    Kernel::pp(m)
    puts "#{_dg}payload:#{_yl}"
    Kernel::pp(m['payload'])
    puts "#{_dg}tree:"
    print_tree(node.lookup_tree(nid), nid) if node
    puts "#{_dg}node:#{_yl}"
    Kernel::pp(n) if n
    puts "#{_dg}nodes:"
    puts nodes_to_s(executor, m, opts)
    z = executor.execution['nodes'].size
    puts "#{_yl}#{z} node#{z == 1 ? '' : 's'}."
    puts "#{_dg}</Flor.detail_msg>#{_rs}"
  end
end

