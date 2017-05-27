
class Flor::Pro::PatGuard < Flor::Pro::PatContainer

  name '_pat_guard'

  # ```
  # _pat_guard name
  # _pat_guard name pattern
  # _pat_guard name conditional
  # _pat_guard name pattern conditional
  # ```

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child

    @node['key'] = nil
  end

  def receive_non_att

    unless @node['key']
      @node['key'] = payload['ret']
      return super
    end

    #ct = child_type(@fcid)

    super
  end

  def receive_last

    payload['_pat_binding'] = { @node['key'] => val }

    super
  end

#  def execute_child(index=0, sub=nil, h=nil)
#
#    return super if @ncid == nil
#pp tree
#p @ncid
#    ct = child_type(@ncid)
#p ct
#
#    super
#  end

#  def receive_non_att
#
#    key = @node['key']
#
#    unless key
#      @node['key'] = payload['ret'].to_s
#      return super
#    end
#
#    b = payload['_pat_binding']
#    b[key] = val if b
#
#    wrap_reply
#  end
#
#  protected
#
#  alias sub_val val
end

