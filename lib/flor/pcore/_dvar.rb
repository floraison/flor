
class Flor::Pro::DoubleQuoteVar < Flor::Procedure

  name '_dvar'

  def execute

    # so far only understands "nid"
    # "exid", "domain", and "tstamp" are procedures on their own

    payload['ret'] =
      case tree[1]
      when 'nid' then parent_node['parent']
      else ''
      end

    wrap_reply
  end
end

