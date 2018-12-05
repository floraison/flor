
class Flor::Pro::Sort < Flor::Procedure

  name 'sort'

  def pre_execute

    @node['col'] = nil # collection
    @node['fun'] = nil # function

    unatt_unkeyed_children
  end

  def receive_non_att

    if @node['partitions']

      quick_receive_partition

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

    quick_execute(0, @node['col'].length - 1)
  end

  def quick_execute(lo, hi)

    #return unless lo < hi # FIXME what should I return? empty list of messages?
    fail "lo < hi" if lo >= hi

    @node['partitions'] ||= {}

    quick_execute_partition(lo, hi)
  end

  def quick_receive(lo, hi, pa)

    quick_execute_partition(lo, pa - 1) +
    quick_execute_partition(pa + 1, hi)
  end

  def quick_execute_partition(lo, hi, j=lo)

#p [ lo, hi, j ]
    np = (@node['partitions'][lo.to_s] ||= {})
    np['lo'] = lo
    np['hi'] = hi
    np['j'] = j
    np['i'] ||= lo - 1

    pivot = @node['col'][hi]

    ms = apply(@node['fun'], [ @node['col'][j], pivot, lo ], tree[2])
      # compare element at j with pivot (element at hi)

    np['sub'] = Flor.sub_nid(ms.first['nid'])
puts "outgoing: #{np.inspect}"
pp ms.first.select { |k, _| %w[ from nid sm vars ].include?(k) }

    ms
  end

  def quick_receive_partition

#pp message
#Kernel.p @node['partitions']
    #p = message['payload'][pap_field_name]

    sn = from_sub_nid
    np = @node['partitions'].values.find { |v| v['sub'] = sn }
    lo, hi, i, j = np['lo'], np['hi'], np['i'], np['j']
    ret = payload_ret
puts; p [ :incoming, lo, np ]
#p payload_ret

    return quick_execute_partition(lo, hi, j + 1) \
      if ret == true || (ret.is_a?(Numeric) && ret < 0)

    i = np['i'] = i + 1
    @node['col'][i], @node['col'][j] = @node['col'][j], @node['col'][i]

    return quick_execute_partition(lo, hi, j + 1) \
      if j < hi

    i = np['i'] = i + 1
    @node['col'][i], @node['col'][hi] = @node['col'][hi], @node['col'][i]

    quick_receive(lo, hi, i)
  end

  # the quicksort as it would look in a non-{execute/receive} world...
  #
#  def quicksort(p, r)
#
#    return unless p < r
#
#    q = partition(p, r)
#
#    quicksort(p, q - 1)
#    quicksort(q + 1, r)
#  end
#
#  def partition(p, r)
#
#    pivot = @node['col'][r]
#    i = p - 1
#
#    for j in p..(r - 1) do
#
#      #next unless @node['col'][j] <= pivot
#      #if ! @node['col'][j] <= pivot
#      if @node['col'][j] > pivot
#        next
#      end
#
#      i = i + 1
#      @node['col'][i], @node['col'][j] =
#        @node['col'][j], @node['col'][i]
#    end
#
#    i = i + 1
#    @node['col'][i], @node['col'][r] =
#      @node['col'][r], @node['col'][i]
#    i
#  end
end

