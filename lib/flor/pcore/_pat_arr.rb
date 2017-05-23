
class Flor::Pro::PatArr < Flor::Pro::PatContainer

  name '_pat_arr'

  def pre_execute

    @node['index'] = 0

    super
  end

  def receive_non_att

    ct = child_type(@fcid)
#p [ :rna, :fcid, @fcid, :index, @node['index'], :ct, ct ]

    offset = 1

    if ct == :pattern

# TODO

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['index']] if ct != '_'

    elsif ct.is_a?(Array)

      offset = val[@node['index']..-1].size - remaining_index_count
      @node['binding'][ct[0]] = val[@node['index'], offset]

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

  def remaining_index_count

    children[@ncid..-1]
      .inject(0) { |count, nact|
        count +
        case (ct = child_type(nact))
        when Array then ct[1] || 1 # FIXME !!!
        when :att then 0
        else 1
        end }
  end
end

