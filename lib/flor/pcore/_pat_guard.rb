
require 'flor/pcore/_pat_'


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

    @node['binding'] = {}
  end

  def receive_non_att

    ct = child_type(@fcid)

    if ct == nil && @node['key'] == nil && payload['ret'].is_a?(String)

      k = payload['ret']

      return wrap_no_match_reply if k == '_'

      m = k.match(Flor::SPLAT_REGEX)
      k = m ? k[0] : k

      @node['key'] = k
      @node['binding'].merge!(k => val) if k != '_'

    elsif ct == nil && payload['ret'] == false

      return wrap_no_match_reply

    elsif ct == :pattern

      b = payload['_pat_binding']
      return wrap_no_match_reply unless b

      if (k = @node['key']) && (m = b['match'])
        b["#{k}__match"] = m
        b["#{k}__matched"] = val
      end

      @node['binding'].merge!(b)
    end

    super
  end

  def receive_last

    payload['_pat_binding'] = @node['binding']

    super
  end

  def execute_child(index=0, sub=nil, h=nil)

    if @node['key'] && child_type(index) == nil
      h ||= {}
      (h['vars'] ||= {}).merge!(@node['binding'])
    end

    super(index, sub, h)
  end
end

