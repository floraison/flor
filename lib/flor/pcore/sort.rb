
class Flor::Pro::Sort < Flor::Procedure

  name 'sort'

  def pre_execute

    @node['col'] = nil # collection
    @node['fun'] = nil # function

    unatt_unkeyed_children
  end

  def receive_non_att

    r = payload['ret']

    if Flor.is_func_tree?(r)
      @node['fun'] ||= r
    elsif Flor.is_collection?(r)
      @node['col'] ||= r
    end

    super
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

  def quick_sort

    quick_execute(0, @node['col'].length)
  end

  def quick_execute(p, r)

    #return unless p < r # FIXME what should I return? empty list of messages?
    fail "p < r" if p >= r

    quick_execute_partition(p, r, nil)
  end

  def quick_execute_partition(p, r, j)

    @node['partitions'] ||= {}
    partition = (@node['partitions'][p] ||= { 'i' => p - 1 })

    j ||= p

    apply(@node['fun'], [ @node['col'][j], @node['col'][r] ], tree[2])
.tap { |x| p x }
      # compare element at j with pivot (element at r)
  end

  # the quicksort as it would look in a non-{execute/receive} world...
  #
#  def quicksort(p, r) # TODO split that in two (apply / receive)
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
#      next unless @node['col'][j] <= pivot # TODO emit messages !
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

