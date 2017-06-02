
require 'flor/pcore/_pat_'


class Flor::Pro::PatArr < Flor::Pro::PatContainer

  name '_pat_arr'

  def pre_execute

    @node['index'] = 0

    super
  end

  def receive_first

    return wrap_no_match_reply unless val.is_a?(Array)

    super
  end

  def receive_non_att

    ct = child_type(@fcid)
#p [ :rna, :fcid, @fcid, :index, @node['index'], :ct, ct ]

    offset = 1

    if ct == :pattern

      if b = payload.delete('_pat_binding')
        offset, _ = @node['_sub_pat_val']
        @node['binding'].merge!(b)
      else
        return wrap_no_match_reply
      end

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['index']] if ct != '_'

    elsif ct.is_a?(Array)

      offset, v = @node['_sub_pat_val']
      @node['binding'][ct[0]] = v if ct[0].length > 0

    elsif val[@node['index']] != payload['ret']

      return wrap_no_match_reply
    end

    @node['index'] = @node['index'] + offset

    super
  end

  def receive_last

    payload['_pat_binding'] = @node['binding']
    payload.delete('_pat_val')

    super
  end

  protected

  def sub_val(child_index)

    ct = child_type(child_index)

    q =
      if ct.is_a?(Array)
        ct
      elsif ct == :pattern
        count_pat(child_index, false)
      else
        nil
      end

    if q && q.is_a?(Array)
      count = val[@node['index']..-1].size - remaining_index_count
      count = q[1] if q[1] && count > q[1]
      sv = val[@node['index'], count]
      [ sv.size, sv ]
    else
      [ 1, val[@node['index']] ]
    end
  end

  def remaining_index_count(ncid=@ncid)

    (ncid + 1..children.size - 1).to_a
      .inject(0) { |count, cid|
        count +
        case (ct = child_type(cid))
        when :att then 0
        when :pattern then count_pat(cid)
        when Array then count_arr(ct)
        else 1
        end }
  end

  def count_arr(a)

    a[1] || 1 # really?
  end

  def count_pat(cid, squash=true)

    ct = children[cid]
    return 1 if ct[0] != '_pat_guard'

    ct = ct[1][0]
    return 1 if ct[1] != []

    m = ct[0].match(Flor::SPLAT_REGEX)
    return 1 if m == nil

    if squash
      m[2] == '_' ? 1 : m[2].to_i
    else
      [ m[1], m[2] == '_' ? nil : m[2].to_i ]
    end
  end
end

