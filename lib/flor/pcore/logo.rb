
class Flor::Pro::Logo < Flor::Procedure
  #
  # "and" has higher precedence than "or"

  names %w[ and or ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    payload['ret'] =
      if @node['heat0'] == 'or'
        !! @node['rets'].index { |r| Flor.true?(r) }
      else
        ! @node['rets'].index { |r| Flor.false?(r) }
      end

    wrap_reply
  end
end

