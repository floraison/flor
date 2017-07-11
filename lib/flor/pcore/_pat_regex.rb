
require 'flor/pcore/_pat_'


class Flor::Pro::PatRegex < Flor::Pro::PatContainer

  name '_pat_regex'

  def execute

    return wrap_no_match_reply unless val.is_a?(String)

    rex = Flor.to_regex(tree[1])
    m = rex.match(val)

    return wrap_no_match_reply unless m

    payload['_pat_binding'] = { 'matched' => val, 'match' => m.to_a }
    payload.delete('_pat_val')

    wrap_reply
  end
end

