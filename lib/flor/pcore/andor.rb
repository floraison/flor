# frozen_string_literal: true

class Flor::Pro::Andor < Flor::Procedure
  #
  # When `and` evaluates the children and returns false as soon
  # as one of returns a falsy value. Returns true else.
  # When `or` evaluates the children and returns true as soon
  # as one of them returns a trueish value. Returns false else.
  #
  # ```
  # and
  #   false
  #   true
  #     # => evaluates to false
  # ```
  #
  # ```
  # and (check_this _) (check_that _)
  # ```
  #
  # Gives priority to `and` over `or`.

  names %w[ and or ]

  def execute

    payload['ret'] = (heap == 'and')

    super
  end

  def receive_att

    c = children[@fcid]; return super if c[0] == '_att' && [1].size == 2

    ret = Flor.true?(payload['ret'])

    return wrap_reply if ((heap == 'or' && ret) || (heap == 'and' && ! ret))

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
#      if heap == 'or'
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

