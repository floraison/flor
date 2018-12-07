
class Flor::Pro::Sort < Flor::Procedure

  # TODO delete @node['ranges'] unused items

  name 'sort'

  def pre_execute

    @node['col'] = nil # collection
    @node['fun'] = nil # function

    unatt_unkeyed_children
  end

  def receive_non_att

    if @node['ranges']

      quick_partition_receive

    else

      r = payload['ret']

      if Flor.is_func_tree?(r)
        @node['fun'] ||= r
      elsif Flor.is_collection?(r)
        @node['col'] ||= r
      end

      super
    end
  end

  def receive_last

    @node['col'] ||= node_payload_ret

    if @node['col'].empty?
      wrap('ret' => @node['col'])
    elsif @node['fun']
      quick_sort
    else
      default_sort
    end
  end

  protected

  def receive_argument

    @node['args'] << payload['ret']

    if children[@ncid]
      execute_child(@ncid)
    else
      iterate
    end
  end

  #
  # default_sort
  #
  # When no function is given, turns to a collection of string
  # (or JSON representations) and sorts

  def default_sort

    col =
      @node['col']
    classes =
      col.collect(&:class).uniq
    f =
      (classes.count > 1 || [ Hash ].include?(classes[0])) ?
      lambda { |e| e.is_a?(String) ? e : JSON.dump(e) } :
      lambda { |e| e }

    ret = col.sort_by(&f)
    ret = col.inject({}) { |h, (k, v)| h[k] = v; h } if col.is_a?(Hash)

    wrap('ret' => ret)
  end

  #
  # quick_sort
  #
  # A quicksort drives the game

  def quick_sort

    col = @node['col']
    @node['colk'] = col.is_a?(Hash) ? 'object' : 'array'
    @node['col'] = col.to_a

    @node['ranges'] = {}
    @node['memo'] = {}

    quick_partition_execute(0, col.length - 1)
  end

  def quick_swap(a, b)

    return if a == b

    col = @node['col']
#puts "    swap 0 #{a}<->#{b} " + col.inspect
    col[a], col[b] = col[b], col[a]
#puts "         1 #{a}<->#{b} " + col.inspect
  end

  def quick_kab(va, vb)

    [ va, vb ]
      .collect { |e|
        case e
        when Array, Hash then Digest::SHA256.hexdigest(JSON.dump(e))
        else JSON.dump(e)
        end }
      .join('__')
  end

  def quick_apply(ra, a, b)

    col = @node['col']
    va, vb = col[a], col[b]

    ra['kab'] = kab = quick_kab(va, vb)
#p ra
#p @node['memo'].keys
    if @node['memo'].has_key?(kab)
      quick_partition_receive(ra['sub'], @node['memo'][kab])
    else
#puts "  apply #{va.inspect} vs #{vb.inspect}"
      ms = apply(@node['fun'], [ va, vb ], tree[2])
      ra['sub'] = Flor.sub_nid(ms.first['nid'])
#puts "  ra sub " + ra.inspect
      ms
    end
  end

  def quick_partition_execute(lo, hi)

#puts "%80s" % @node['col'].inspect
#p [ :qp_execute, lo, hi ]
#puts "  lo: #{lo}, hi: #{hi}, #{@node['col'][lo..hi].inspect}"
    return [] if lo >= hi
#puts @node['ranges'].any? ? "  ranges:" : "  no ranges"
#@node['ranges'].each do |k, v| puts "    #{k}: #{v.inspect}"; end

    ra = @node['ranges']["#{lo}_#{hi}"] ||= { 'i' => lo, 'j' => lo }
#puts "  ra:   " + ra.inspect

    quick_apply(ra, ra['j'], hi)
      # compare element at j with pivot (element at hi)
  end

  def quick_partition_receive(sn=from_sub_nid, ret=payload_ret)

#puts "%80s" % @node['col'].inspect
    #sn = from_sub_nid
    rk, ra = @node['ranges'].find { |_, v| v['sub'] == sn }
    lo, hi = rk.split('_').collect(&:to_i)
    i, j = ra['i'], ra['j']
    #ret = payload_ret
    @node['memo'][ra['kab']] = ret =
      (ret == true || (ret.is_a?(Numeric) && ret < 0))
    col = @node['col']
#p [ :qp_receive, lo, hi ]
#puts "  ret:  " + ret.inspect
#puts "  ra:   " + ra.inspect

    if ret
      quick_swap(i, j)
      ra['i'] = i = (i + 1)
#puts "  ra i++ " + ra.inspect
    end

    ra['j'] = j = (j + 1)
#puts "  ra j++ " + ra.inspect

    return quick_partition_execute(lo, hi) if j < hi # loop on

    quick_swap(i, hi)

#puts "  partition at #{i}"
    @node['ranges'].delete(rk)

    ms =
      quick_partition_execute(lo, i - 1) +
      quick_partition_execute(i + 1, hi)

    if ms.any?
      ms
    elsif @node['ranges'].any?
      []
    else # quicksort is over
      wrap('ret' => (@node['colk'] === 'object' ? Hash[col] : col))
    end
  end
end

