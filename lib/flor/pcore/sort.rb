
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

    if @node['fun']
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

  def pap_field_name; "__#{@node['heat0']}__#{nid}__partition_p"; end

  def quick_sort

    quick_execute(0, @node['col'].length - 1)
  end

  def quick_execute(p, r)

    #return unless p < r # FIXME what should I return? empty list of messages?
    fail "p < r" if p >= r

    quick_execute_partition(p, r, nil)
  end

  def quick_execute_partition(p, r, j)

#Kernel.p [ p, r, j ]
    @node['partitions'] ||= {}

    pa = (@node['partitions'][p.to_s] ||= { 'r' => r })
    pa['i'] ||= p - 1
    pa['j'] = (j ||= p)

    apply(
      @node['fun'],
      [ @node['col'][j], @node['col'][r], p ],
      tree[2],
      fields: { pap_field_name => p })
.tap { |m|
  #p m.first.keys
  p m.first.select { |k, _| %w[ from nid sm vars ].include?(k) } }
      # compare element at j with pivot (element at r)
  end

  def quick_receive_partition

#pp message
Kernel.p @node['partitions']
    p = message['payload'][pap_field_name]
    pa = @node['partitions'][p.to_s]
    ret = payload_ret
Kernel.p [ :incoming, p, pa ]
Kernel.p payload_ret
    i, j, r = pa['i'], pa['j'], pa['r']

    #next if @node['col'][j] > pivot
    if ret == true || (ret.is_a?(Numeric) && ret < 0)
      quick_execute_partition(p, r, j + 1)
    else
      i = pa['i'] = i + 1
      @node['col'][i], @node['col'][j] = @node['col'][j], @node['col'][i]
      if j < r
        quick_execute_partition(p, r, j + 1)
      else
        i = pa['i'] = i + 1
        @node['col'][i], @node['col'][r] = @node['col'][r], @node['col'][i]
fail
      end
    end
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

