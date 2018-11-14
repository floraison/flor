
class Flor::Pro::Val < Flor::Procedure

  name '_val'

  def wrap_reply

    payload['ret'] = tree_to_value(@node['heat']) \
      if node_open?

    super
  end

  protected

  def tree_to_value(t)

    case t[0]
    when '_func', '_proc', '_tasker' then t
    else t[1]
    end
  end
end

