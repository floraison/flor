
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

  def next_child_is_a_else?

    t = tree[1][@ncid][0, 2]

    t == [ 'else', [] ] ||
    t == [ '_', [] ]
  end
end

