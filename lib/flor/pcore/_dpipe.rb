
class Flor::Pro::Dpipe < Flor::Procedure

  name '_dpipe'

  def execute

    ret = payload['ret']

    payload['ret'] =
      case tree[1]
      when 'd' then ret.downcase
      else ret
      end

    wrap
  end
end

