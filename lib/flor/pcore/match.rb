
class Flor::Pro::Match < Flor::Pro::Case

  name 'match'

  def pre_execute

    unatt_unkeyed_children

    conditional = true
    @node['val'] = payload['ret'] if non_att_children.size.even?
    found_val = @node.has_key?('val')
    t = tree
    changed = false

    t[1].each_with_index do |ct, i|

      next if ct[0] == '_att'
      next(found_val = true) unless found_val
      next(conditional = true) unless conditional

      conditional = false
      t[1][i] = patternize(ct)
      changed = changed || t[1][i] != ct
    end

    @node['tree'] = t if changed
  end

  def execute_child(index=0, sub=nil, h=nil)

    t = tree[1][index]

    payload['_pat_val'] = @node['val'] \
      if t && t[0].match(/\A_pat_(arr|obj|guard|bind)\z/)

    super
  end

  protected

  def patternize(t)

    return t unless t[1].is_a?(Array)

    bang = t[1]
      .index { |ct|
        ct[0] == '_att' &&
        ct[1].size == 1 &&
        ct[1][0][0, 2] == [ '!', [] ] }
    pat =
      case t[0]
      when '_arr', '_obj' then "_pat#{t[0]}"
      when 'or', 'bind', 'guard' then "_pat_#{t[0]}"
      when 'or!' then 'or'
      else nil
      end

    t[0] =
      if pat && bang
        t[1].delete_at(bang)
        t[0]
      elsif pat
        pat
      else
        t[0]
      end

    t[1].each_with_index { |ct, i| t[1][i] = patternize(t[1][i]) }

    t
  end

  def match?

    if b = payload.delete('_pat_binding')
      b
    else
      payload['ret'] == @node['val']
    end
  end

  def else?(ncid)

    t = tree[1][ncid]; return false unless t

    t[0, 2] == [ '_', [] ] ||
    t[0, 2] == [ 'else', [] ]
  end
end

