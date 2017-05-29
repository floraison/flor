
class Flor::Pro::PatGuard < Flor::Pro::PatContainer

  name '_pat_guard'

  # ```
  # _pat_guard name
  # _pat_guard name pattern
  # _pat_guard name conditional
  # _pat_guard name pattern conditional
  # _pat_guard name conditional pattern
  # ```

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child
  end

  def receive_non_att

    ct = child_type(@fcid)

    if ct == nil && @node['key'] == nil && payload['ret'].is_a?(String)

      @node['key'] = payload['ret']

    elsif ct == nil && payload['ret'] == false

      return wrap_no_match_reply

    elsif ct == :pattern

      b = payload['_pat_binding']
      return wrap_no_match_reply unless b

      @node['binding'] = b
    end

    super
  end

  def receive_last

    payload['_pat_binding'] =
      if k = @node['key']
        (@node['binding'] || {}).merge!(k => val)
      else
        @node['binding'] || {}
      end

    super
  end

  def execute_child(index=0, sub=nil, h=nil)

    if (key = @node['key']) && child_type(index) == nil
      h ||= {}
      h['vars'] ||= {}
      h['vars'][key.to_s] = val
    end

    super(index, sub, h)
  end

  protected

  alias sub_val val
end

