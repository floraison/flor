
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

    @node['rets'] = []
  end

  def receive_last

#p [ 0, @node['rets'] ]
    key = grab { |e| e.is_a?(String) }
    boo = grab { |e| e == false || e == true }
    pat = @node['rets'].pop
#p({ key: key, boo: boo, pat: pat })
#p [ 1, @node['rets'] ]

    payload['_pat_binding'] =
      if boo == false
        nil
      elsif key
        { key => val }
      else
        {}
      end

    super
  end

  def execute_child(index=0, sub=nil, h=nil)

    if (key = @node['rets'].first) && child_type(index) == nil
      h ||= {}
      h['vars'] ||= {}
      h['vars'][key.to_s] = val
    end

    super(index, sub, h)
  end

  protected

  def grab(&block)

    if i = @node['rets'].index(&block)
      @node['rets'].delete_at(i)
    else
      nil
    end
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

