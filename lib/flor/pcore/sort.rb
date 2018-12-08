
class Flor::Pro::Sort < Flor::Procedure
  #
  # Sorts an array or an object.
  #
  # "sort" takes an array or an object and sorts its content.
  #
  # ```
  # sort [ 0 7 1 5 3 4 2 6 ]
  #   # => [ 0 1 2 3 4 5 6 7 ]
  # ```
  #
  # Without a function, "sort" uses the underlying (Ruby) sort methods.
  #
  # One can use a function to sort in specific ways:
  # ```
  # [ { name: 'Alice', age: 33, function: 'ceo' }
  #   { name: 'Bob', age: 44, function: 'cfo' }
  #   { name: 'Charly', age: 27, function: 'cto' } ]
  # sort (def a b \ - a.age b.age)
  # ```
  #
  # The function should return a boolean or a number. `true` or a negative
  # number indicates `a` comes  before `b`, anything else indicates `a`
  # comes after `b`.
  #
  # ## behind the scenes
  #
  # Sorting an array results in a sorted array stored in `f.ret`, sorting
  # an object results in a sorted (entries) object stored in `f.ret`.
  #
  # Using a function to sort is quite slow. Behind the scene a quicksort is
  # used, to lower the number of calls to the sort function, but since
  # the function is a flor function, calls are quite costly.
  # By default, "sort" will cache the call results. For example, upon
  # comparing 1 with 7, the results will be cached (the 7 vs 1 will be cached
  # as well).
  #
  # It's OK to disable this caching:
  # ```
  # sort memo: false a (def a b \ < a b)
  # ```
  # (but why should we need that?)
  #
  # ## see also
  #
  # sort_by, reverse, shuffle

  name 'sort'

  def pre_execute

    @node['atts'] = []

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

    @node['memo'] =
      att('memo', 'cache') == false ?
      nil :
      {}

    quick_partition_execute(0, col.length - 1)
  end

  def quick_swap(a, b)

    return if a == b

    col = @node['col']
    col[a], col[b] = col[b], col[a]
  end

  def quick_kab(va, vb)

    return [] unless @node['memo']

    kab = [ va, vb ]
      .collect { |e|
        case e
        when Array, Hash, String then Digest::SHA256.hexdigest(JSON.dump(e))
        else JSON.dump(e)
        end }

    [ kab.join('__'), kab.reverse.join('__') ]
  end

  def quick_compare(ra, a, b)

    col = @node['col']
    va, vb = col[a], col[b]

    ra['kab'], ra['kba'] = quick_kab(va, vb)
    kab = ra['kab']

    if kab && @node['memo'].has_key?(kab)
      quick_partition_receive(ra['sub'], @node['memo'][kab])
    else
      apply(@node['fun'], [ va, vb ], tree[2])
        .tap { |ms| ra['sub'] = Flor.sub_nid(ms.first['nid']) }
    end
  end

  def quick_partition_execute(lo, hi)

    return [] if lo >= hi

    ra = @node['ranges']["#{lo}_#{hi}"] ||= { 'i' => lo, 'j' => lo }

    quick_compare(ra, ra['j'], hi)
      # compare element at j with pivot (element at hi)
  end

  def quick_partition_receive(sn=from_sub_nid, r=:none)

    rk, ra = @node['ranges'].find { |_, v| v['sub'] == sn }
    lo, hi = rk.split('_').collect(&:to_i)
    i, j = ra['i'], ra['j']

    if r == :none
      ret = payload_ret
      r = ret == true || (ret.is_a?(Numeric) && ret < 0)
      if m = @node['memo']
        m[ra['kab']], m[ra['kba']] = r, ! r
      end
    end

    if r
      quick_swap(i, j)
      ra['i'] = i = (i + 1)
    end

    ra['j'] = j = (j + 1)

    return quick_partition_execute(lo, hi) if j < hi # loop on

    # partition loop is over...

    quick_swap(i, hi)

    @node['ranges'].delete(rk)

    # partition at i...

    ms =
      quick_partition_execute(lo, i - 1) +
      quick_partition_execute(i + 1, hi)

    if ms.any?
      ms
    elsif @node['ranges'].any?
      []
    else # quicksort is over
      col = @node['col']
      wrap('ret' => (@node['colk'] === 'object' ? Hash[col] : col))
    end
  end
end

