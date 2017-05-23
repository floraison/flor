
class Flor::Pro::PatObj < Flor::Pro::PatContainer

  name '_pat_obj'

  def pre_execute

    @node['atts'] = []

    key = true

    cn = children
      .collect { |ct|
        next ct if ct[0] == '_att'
        (key = ! key) ? ct : deref_and_stringify(ct) }

    t = tree

    @node['tree'] = [ t[0], cn, *t[2..-1] ] if cn != t[1]

    super
  end

# TODO
#
# It’s also useful to specify that some map has only a set of specified keys,
# this can be accomplished with the :only map pattern modifier:
#
# ```
# _pat_obj
#   _att \ only
#   a; _
#   b; 1
# ```

  def receive_first

    return wrap_no_match_reply if ! val.is_a?(Hash)

    super
  end

  def receive_last_att

    @node['key'] = nil

# TODO deal with `only`, @node['seen'] = []...
    super
  end

  def receive_non_att

    key = @node['key']
    ret = payload['ret']

    unless key
      return wrap_no_match_reply unless val.has_key?(ret)
      @node['key'] = ret
      return super
    end

    ct = child_type(@fcid)

    if ct == :pattern

# TODO

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['key']] if ct != '_'

    elsif ct.is_a?(Array)

#p [ :else, ct ]
# TODO

    elsif val[key] != ret

      return wrap_no_match_reply unless val[key] == ret
    end

    @node['key'] = nil

    super
  end

  def receive_last

#p :rl
    payload['_pat_binding'] = @node['binding']
    payload.delete('_pat_val')

    super
  end
end

