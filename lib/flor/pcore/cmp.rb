
class Flor::Pro::Cmp < Flor::Procedure

  names %w[ = == < > ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    payload['ret'] =
      if @node['rets'].size > 1
        case tree[0]
          when '=', '==' then check_equal
          when '<', '>' then check_lesser
          else true
        end
      else
        true
      end

    wrap_reply
  end

  protected

  def check_equal

    @node['rets'].first == @node['rets'].last
  end

  def check_lesser

    a, b = @node['rets'][-2], @node['rets'][-1]

    case tree[0]
      when '<' then return false if a >= b
      when '<=' then return false if a > b
      when '>' then return false if a <= b
      when '>=' then return false if a < b
    end

    true
  end
end

