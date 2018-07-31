
module Flor
  class << self

    # Turns a flor message into a one line string.
    # Used when logging messages.
    #
    def message_to_one_line_s(executor, m, opts={})

      _c = colours(opts)

      nid = m['nid']
      nd = executor.node(nid)

      a = [ '  ' ]

      n = Time.now.utc
      a <<
        opts[:date] ?
        n.strftime('%Y%m%d.%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4] :
        n.strftime('%H:%M:%S') + sprintf('.%06d', n.usec)[0, 4]
      a << ' ' << _c.dg

      if ex = (m['exid'] || '').split('.').last
        a << ex[-4..-1] << ' '
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

      t = m['tree']
      rw = (t && m['rewritten']) ? 'rw->' : ''
      nt = t || Node.new(executor, nd, m).lookup_tree(nid)
      a <<
        if t
          " [#{rw}#{_c.yl}#{Flor.to_d(t[0], compact: true)}#{_c.dg} L#{t[2]}]"
        elsif nt
          " [#{_c.dg}#{Flor.to_d(nt[0], compact: true)}#{_c.dg} L#{nt[2]}]"
        else
          ''
        end

      a << m['on_error'] ? " #{_c.rd}on_error" : ''

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

      a << (m['from'] ? " from #{m['from']}" : '')

      if cs = m['cause']
        a << " <" << cs
          .collect { |c|
            [ c['cause'][0, 2], c['nid'], "m#{c['m']}", c['type'] ]
              .compact.join(':') }
          .join('<')
      end

      rt = ret_to_s(executor, m, _c)
      rt = rt.length > 0 ? " #{_c.lg}f.ret #{rt}" : ''
      a << rt

      a << (
        (m['point'] == 'entered' || m['point'] == 'left') ?
        " #{_c.dg}tags:#{_c.gr}#{m['tags'].join(',')}" :
        nil)

      a << (
        (nd && nd['vars']) ?
        " #{_c.dg}vars:#{_c.gr}#{nd['vars'].keys.join("#{_c.dg},#{_c.gr}")}" :
        '')

      %w[ fpoint dbg ].each do |k|
        a << " #{_c.dg}#{k}:#{m[k]}" if m.has_key?(k)
      end

      a << _c.rs

      a.join
    end # message_to_one_line_s

    def src_to_s(src, launch_opts, opts={})

      o = StringIO.new
      _c = colours(opts)

      o.puts "#{_c.dg}+---#{_c.rs}"

      if launch_opts.any?
        o.puts "#{_c.dg}| #{Flor.to_d(launch_opts, compact: true)}#{_c.rs}"
        o.puts "#{_c.dg}|#{_c.rs}"
      end

      lines =
        (src.is_a?(String) ? src : Flor.to_pretty_s(src))
          .split("\n")
      min = lines
        .select { |l| l.strip.length > 0 }
        .collect { |l| l.match(/\A(\s*)/)[1].length }
        .min
      lines
        .each_with_index { |l, i|
          o.puts "#{_c.dg}|#{"%4d" % (i + 1)} #{_c.yl}#{l[min..-1]}#{_c.rs}" }

      o.puts "#{_c.dg}.#{_c.rs}"

      o.string
    end # src_to_s

    def tree_to_s(tree, nid='0', opts={})

      t0, t1, t2 = (tree || [])

      o = StringIO.new
      _c = colours(opts)

      ind = ' ' * (opts[:ind] || 0)

      headers = opts[:headers]; headers = true if headers.nil?
      headers = true if opts[:title]

      h = "#{_c.yl}#{Flor.to_d(t0, opts.merge(compact: true))}"
      c = t1.is_a?(Array) ? '' : " #{_c.yl}#{t1}"
      l = " #{_c.dg}L#{t2}"

      o.puts "#{ind}#{_c.dg}+--- #{opts[:title]}#{_c.rs}" if headers && nid == '0'
      o.puts "#{ind}#{_c.dg}| #{nid} #{h}#{c}#{l}#{_c.rs}"
      t1.each_with_index { |ct, i|
        o.puts tree_to_s(ct, Flor.child_nid(nid, i), opts) } if t1.is_a?(Array)
      o.puts "#{ind}#{_c.dg}.#{_c.rs}" if headers && nid == '0'

      o.string
    end

    def to_flat_tree_s(tree, nid, opts)

      o = StringIO.new
      _c = colours(opts)

      o << ' ' << nid << ' ' << _c.yl << tree[0] << _c.dg

      if tree[1].is_a?(Array)
        tree[1].each_with_index do |t, i|
          o << to_flat_tree_s(t, "#{nid}_#{i}", opts)
        end
      else
        o << ' ' << tree[1]
      end

      o.string
    end

    def to_compact_tree_s(tree, nid='0', opts={})

      o = StringIO.new
      _c = colours(opts)

      #is_root = opts[:s].nil?
      ind = ' ' * (opts[:ind] || 0)

      atts, natts =
        tree[1].is_a?(Array) ?
        tree[1].partition { |t| Flor.is_att_tree?(t) } :
        [ [], [] ]

      if t = opts.delete(:title)
        o << ind << _c.dg << '+--- ' << t << "\n"
      end

      o <<
        ind << _c.dg << '| ' << nid << ' ' <<
        _c.yl << Flor.to_d(tree[0], opts.merge(compact: true)) <<
        _c.dg << ' L' << tree[2]

      atts.each_with_index do |ct, i|
        o << to_flat_tree_s(ct, "_#{i}", opts)
      end

      natts.each_with_index do |ct, i|
        i = atts.size + i
        o << "\n" << to_compact_tree_s(ct, "#{nid}_#{i}", opts)
      end

      #o << "\n" << ind << _c.dg << '\---' if is_root && opts[:close]
      o << "\n" << ind << _c.dg << '\---' if opts[:close]

      o << _c.rs

      #opts[:out].puts(s.string) if is_root

      o.string
    end

    def ret_to_s(executor, m, c)

      ret = (m['payload'] || {})['ret']
      s = Flor.to_d(ret, compact: true)
      Flor.truncate_string(s, 35, Proc.new { |x| "#{c.dg}... (ln#{x})#{c.rs}" })
    end

    def nod_to_s(executor, n, opts, here=false)

      _c = colours(opts)

      t = n['tree'] || Node.new(executor, n, nil).lookup_tree(n['nid'])
      if t
        t = Flor.to_d(t, compact: true)
        t = Flor.truncate_string(t, 42)
      end

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

    def ncns_to_s(executor, ncn, msg, opts, sio, ind, seen)

      n, cn = ncn
      nid = n['nid']

      return if seen.include?(nid)
      seen << nid

      sio.print(ind)
      sio.print(nod_to_s(executor, n, opts, nid == msg['nid']))
      sio.print("\n")
      cn.each { |c| ncns_to_s(executor, c, msg, opts, sio, ind + ' ', seen) }
    end

    def nods_to_s(executor, msg, opts)

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

    def msg_to_detail_s(executor, m, opts={})

      return if m['_detail_msg_flag']
      m['_detail_msg_flag'] = true if opts[:flag]

      o = StringIO.new
      _c = colours(opts)

      nid = m['nid']
      n = executor.execution['nodes'][nid]
      node = n ? Flor::Node.new(executor, n, m) : nil

      o.puts "#{_c.dg}<Flor.msg_to_detail_s>#{_c.rs}#{_c.yl}"
      o.puts Flor.to_pretty_s(m)
      o.puts "#{_c.dg}payload:#{_c.yl}"
      o.puts Flor.to_pretty_s(m['payload'], 0)
      o.puts "#{_c.dg}tree:"
      o.puts(tree_to_s(node.lookup_tree(nid), nid, out: o)) if node
      o.puts "#{_c.dg}node:#{_c.yl}"
      o.puts(Flor.to_pretty_s(n)) if n
      o.puts "#{_c.dg}nodes:"
      o.puts nods_to_s(executor, m, opts)
      z = executor.execution['nodes'].size
      o.puts "#{_c.yl}#{z} node#{z == 1 ? '' : 's'}."
      o.puts "#{_c.dg}</Flor.msg_to_detail_s>#{_c.rs}"

      o.string
    end
  end
end

