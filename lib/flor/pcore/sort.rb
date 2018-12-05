
class Flor::Pro::Sort < Flor::Procedure

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

    wrap('ret' => col.sort_by(&f))
  end

  #
  # quick_sort
  #
  # A quicksort drives the game

  def quick_sort

    @node['ranges'] ||= {}

    #quicksort(0, @node['col'].length - 1)
    quick_partition_execute(0, @node['col'].length - 1)
  end

  def quick_partition_execute(lo, hi)

    return [] if lo >= hi

    col = @node['col']
    rk = "#{lo}_#{hi}"
    ra = @node['ranges'][rk] ||= { 'i' => lo, 'j' => lo }
    i, j = ra['i'], ra['j']

    pivot = col[hi]

    ms = apply(@node['fun'], [ col[j], pivot, lo ], tree[2])
      # compare element at j with pivot (element at hi)

    ra['sub'] = Flor.sub_nid(ms.first['nid'])

    ms
  end

  def quick_partition_receive

    sn = from_sub_nid
    rk, ra = @node['ranges'].find { |_, v| v['sub'] == sn }
    lo, hi = rk.split('_').collect(&:to_i)
    i, j = ra['i'], ra['j']
    ret = payload_ret
    col = @node['col']

    if ret == true || (ret.is_a?(Numeric) && ret < 0)
      col[i], col[j] = col[j], col[i]
      ra['i'] = i = (i + 1)
    end

    ra['j'] = j = (j + 1)

    return quick_partition_execute(lo, hi) if j < hi # loop on

    col[i], col[hi] = col[hi], col[i]

    ms =
      quick_partition_execute(lo, i - 1) +
      quick_partition_execute(i + 1, hi)

    ms.any? ? ms : wrap('ret' => col)
  end
end

