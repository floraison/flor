
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

  def quick_sort

    quicksort(0, @node['col'].length)
  end

  def quicksort(p, r) # TODO split that in two (apply / receive)

    return unless p < r

    q = partition(p, r)

    quicksort(p, q - 1)
    quicksort(q + 1, r)
  end

  def partition(p, r)

    pivot = @node['col'][r]
    i = p - 1

    for j in p..(r - 1) do

      next unless @node['col'][j] <= pivot # TODO emit messages !

      i = i + 1
      @node['col'][i], @node['col'][j] =
        @node['col'][j], @node['col'][i]
    end

    i = i + 1
    @node['col'][i], @node['col'][r] =
      @node['col'][r], @node['col'][i]
    i
  end
end

