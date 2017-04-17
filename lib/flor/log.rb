
module Flor

  def self.log_message(executor, m, opts={})

    return if m['point'] == 'end'

    _c = colours(opts)

    nid = m['nid']
    nd = executor.node(nid)

    a = [ '  ' ]

    n =
      Time.now.utc
    tm =
      if opts[:date]
        n.strftime('%Y%m%d.%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      else
        n.strftime('%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      end
    a << tm
    a << ' '
    a << _c.dg

    if ex = (m['exid'] || '').split('.').last
      a << ex[-4..-1]
      a << ' '
    end

    a << "#{nd ? _c.dg : _c.dim + _c.dg}#{nid}#{_c.rs}#{_c.dg} " if nid

    pt = m['point'][0, 3]
    _pt =
      case pt
        when 'tri', 'sig' then _c.gr
        when 'cea', 'ter' then _c.lg
        when 'can' then _c.ma
        else _c.bl
      end
    a << "#{_pt}#{pt}#{_c.dg}"

    fla = m['flavour']
    a << " #{_c.lg}#{fla}#{_c.dg}" if fla

    st = nd && nd['status'].last
    a << " #{_c.dim}#{_c.lg}#{st['status']}:#{st['flavour']}#{_c.rs}#{_c.dg}" \
      if st && st['status']

    t =
      m['tree']
    rw =
      (t && m['rewritten']) ? 'rw->' : ''
    nt =
      t || Node.new(executor, nd, m).lookup_tree(nid)
    t0 =
      if t
        " [#{rw}#{_c.yl}#{Flor.to_d(t[0], compact: true)}#{_c.dg} L#{t[2]}]"
      elsif nt
        " [#{_c.dg}#{Flor.to_d(nt[0], compact: true)}#{_c.dg} L#{nt[2]}]"
      else
        ''
      end
    a << t0

    oe = m['on_error'] ? " #{_c.rd}on_error" : ''
    a << oe

    tmi = m['timer_id']
    tmi = tmi ? " #{_c.dg}tmi:#{tmi}" : ''
    a << tmi
      #
    tri = m['trap_id']
    tri = tri ? " #{_c.dg}tri:#{tri}" : ''
    a << tri

    cn = t ? " #{_c.dg}#{Flor.to_d(t[1], compact: true, inner: true)}" : ''
    cn = Flor.truncate_string(cn, 49, "#{_c.dg}...#{_c.rs}")
    a << cn

    hp = nd && nd['heap']
    hp = hp && (hp != (t || [])[0]) ? " #{_c.dg}hp:#{nd['heap']}" : ''
    a << hp

    msr = " #{_c.dg}m#{m['m']}s#{m['sm'] || '_'}"
    msr << "r#{m['er']}>#{m['pr']}" if m['er'] && m['er'] > -1
    a << msr

    fr = m['from'] ? " from #{m['from']}" : ''
    a << fr

    rt = ret_to_s(executor, m, _c)
    rt = rt.length > 0 ? " #{_c.lg}f.ret #{rt}" : ''
    a << rt

    ta =
      m['point'] == 'entered' || m['point'] == 'left' ?
      " #{_c.dg}tags:#{_c.gr}#{m['tags'].join(',')}" :
      nil
    a << ta

    vs =
      (nd && nd['vars']) ?
      " #{_c.dg}vars:#{_c.gr}#{nd['vars'].keys.join("#{_c.dg},#{_c.gr}")}" :
      ''
    a << vs

    %w[ fpoint dbg ].each do |k|
      a << " #{_c.dg}#{k}:#{m[k]}" if m.has_key?(k)
    end

    a << _c.rs

    (opts[:out] || $stdout).puts a.join
  end

  def self.print_src(src, opts={}, log_opts={})

    o = (log_opts[:out] ||= $stdout)
    _c = colours(log_opts)

    o.puts "#{_c.dg}+---#{_c.rs}"

    o.puts "#{_c.dg}| #{opts.inspect}#{_c.rs}" if opts.any?

    if src.is_a?(String)
      src.split("\n")
        .select { |l| l.strip.length > 0 && l.match(/\A\s*[^#]/) }
        .each { |l| o.puts "#{_c.dg}| #{_c.yl}#{l}#{_c.rs}" }
    else
      Flor.to_pretty_s(src).split("\n")
        .each { |l| o.puts "#{_c.dg}| #{_c.yl}#{l}#{_c.rs}" }
    end

    o.puts "#{_c.dg}.#{_c.rs}"

    o.is_a?(StringIO) ? o.string : nil
  end

  def self.print_tree(tree, nid='0', opts={})

    t0, t1, t2 = (tree || [])

    o = (opts[:out] ||= $stdout)
    _c = colours(opts)

    ind = ' ' * (opts[:ind] || 0)

    headers = opts[:headers]; headers = true if headers.nil?
    headers = true if opts[:title]

    h = "#{_c.yl}#{Flor.to_d(t0, compact: true)}"
    c = t1.is_a?(Array) ? '' : " #{_c.yl}#{t1}"
    l = " #{_c.dg}L#{t2}"

    o.puts "#{ind}#{_c.dg}+--- #{opts[:title]}#{_c.rs}" if headers && nid == '0'
    o.puts "#{ind}#{_c.dg}| #{nid} #{h}#{c}#{l}#{_c.rs}"
    if t1.is_a?(Array)
      t1.each_with_index { |ct, i| print_tree(ct, Flor.child_nid(nid, i), opts) }
    end
    o.puts "#{ind}#{_c.dg}.#{_c.rs}" if headers && nid == '0'

    o.is_a?(StringIO) ? o.string : nil
  end

  def self.print_flat_tree(tree, nid, opts)

    _c = colours(opts)

    s = opts[:s]

    s << ' ' << nid << ' ' << _c.yl << tree[0] << _c.dg

    if tree[1].is_a?(Array)
      tree[1].each_with_index do |t, i|
        print_flat_tree(t, "#{nid}_#{i}", opts)
      end
    else
      s << ' ' << tree[1]
    end
  end

  def self.print_compact_tree(tree, nid='0', opts={})

    _c = colours(opts)

    is_root = opts[:s].nil?
    ind = ' ' * (opts[:ind] || 0)

    atts, natts =
      tree[1].is_a?(Array) ?
      tree[1].partition { |t| Flor.is_att_tree?(t) } :
      [ [], [] ]

    s = (opts[:s] ||= StringIO.new)

    if t = opts.delete(:title)
      s << ind << _c.dg << '+--- ' << t << "\n"
    end

    s << ind << _c.dg << '| ' << nid << ' '
    s << _c.yl << Flor.to_d(tree[0], compact: true) << _c.dg << ' L' << tree[2]

    atts.each_with_index do |ct, i|
      print_flat_tree(ct, "_#{i}", opts)
    end

    natts.each_with_index do |ct, i|
      i = atts.size + i
      s << "\n"
      print_compact_tree(ct, "#{nid}_#{i}", opts)
    end

    s << "\n" << ind << _c.dg << '\---' if is_root && opts[:close]

    s << _c.rs

    opts[:out].puts(s.string) if is_root
  end

  def self.ret_to_s(executor, m, c)

    ret = (m['payload'] || {})['ret']
    s = Flor.to_d(ret, compact: true)
    Flor.truncate_string(s, 35, Proc.new { |x| "#{c.dg}... (L#{x})#{c.rs}" })
  end

  def self.nod_to_s(executor, n, opts, here=false)

    _c = colours(opts)

    t = n['tree'] || Node.new(executor, n, nil).lookup_tree(n['nid'])
    t = Flor.to_d(t, compact: true) if t
    t = Flor.truncate_string(t, 42);

    h = {}
    %w[ parent cnid noreply dbg ].each do |k|
      h[k] = n[k] if n.has_key?(k)
    end

    dbg = n['dbg'] ? "dbg:#{n['dbg']}" : nil
    nr = n.has_key?('noreply') ? "nr:#{n['noreply']}" : nil
    h = h.collect { |k, v| "#{k}:#{v}" }.join(' ')

    vs = n['vars']
    vs = 'vars:' + vs.keys.join(',') if vs
    ts = n['tags']
    ts = 'tags:' + ts.join(',') if ts

    flr = n['failure'] ? "#{_c.rd}flre" : ''

    here = here ? "#{_c.dg}<---msg['nid']" : nil

    [ _c.yl + n['nid'], t, h, ts, vs, flr, here ].compact.join(' ')
  end

  def self.ncns_to_s(executor, ncn, msg, opts, sio, ind, seen)

    n, cn = ncn
    nid = n['nid']

    return if seen.include?(nid)
    seen << nid

    sio.print(ind)
    sio.print(nod_to_s(executor, n, opts, nid == msg['nid']))
    sio.print("\n")
    cn.each { |c| ncns_to_s(executor, c, msg, opts, sio, ind + ' ', seen) }
  end

  def self.nods_to_s(executor, msg, opts)

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

  def self.print_detail_msg(executor, m, opts={})

    return if m['_detail_msg_flag']
    m['_detail_msg_flag'] = true if opts[:flag]

    o = (opts[:out] ||= $stdout)
    _c = colours(opts)

    nid = m['nid']
    n = executor.execution['nodes'][nid]
    node = n ? Flor::Node.new(executor, n, m) : nil

    o.puts "#{_c.dg}<Flor.print_detail_msg>#{_c.rs}#{_c.yl}"
    o.puts(Flor.to_pretty_s(m))
    o.puts "#{_c.dg}payload:#{_c.yl}"
    o.puts(Flor.to_pretty_s(m['payload'], 0))
    o.puts "#{_c.dg}tree:"
    print_tree(node.lookup_tree(nid), nid, out: o) if node
    o.puts "#{_c.dg}node:#{_c.yl}"
    o.puts(Flor.to_pretty_s(n)) if n
    o.puts "#{_c.dg}nodes:"
    o.puts nods_to_s(executor, m, opts)
    z = executor.execution['nodes'].size
    o.puts "#{_c.yl}#{z} node#{z == 1 ? '' : 's'}."
    o.puts "#{_c.dg}</Flor.print_detail_msg>#{_c.rs}"

    o.is_a?(StringIO) ? o.string : nil
  end
end

