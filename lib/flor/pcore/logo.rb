
class Flor::Pro::Logo < Flor::Procedure

  names %w[ and or ]

  def execute

    payload['ret'] = @node['heat0'] == 'and'

    super
  end

  def receive_att

    c = children[@fcid]; return super if c[0] == '_att' && [1].size == 2

    h0 = @node['heat0']

    ret = Flor.true?(payload['ret'])

    return wrap_reply if ((h0 == 'or' && ret) || (h0 == 'and' && ! ret))

    super
  end

  alias receive_non_att receive_att

#  def pre_execute
#
#    @node['rets'] = []
#  end
#
#  def receive_last
#
#    payload['ret'] =
#      if @node['heat0'] == 'or'
#        !! @node['rets'].index { |r| Flor.true?(r) }
#      else
#        ! @node['rets'].index { |r| Flor.false?(r) }
#      end
#
#    wrap_reply
#  end
  #
  # Keep me around for a "aand" and a "oor"... Maybe...
end

