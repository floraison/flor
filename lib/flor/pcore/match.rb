
class Flor::Pro::Match < Flor::Pro::Case

  name 'match'

  protected

  def match?

#p [ :m, @node['val'], payload['ret'] ]
    case (v = @node['val'])
    when Array then match_array?
    when Hash then match_object?
    else v == payload['ret']
    end
  end

  def match_array?

#p :ma?
false
  end

  def match_object?

false
  end

  def else?(ncid)

    t = tree[1][ncid]; return false unless t

    t[0, 2] == [ '_', [] ] ||
    t[0, 2] == [ 'else', [] ]
  end
end

