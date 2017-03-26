
class Flor::Pro::NoEval < Flor::Procedure
  #
  # Immediately replies, children are not evaluated
  #
  # ```
  # sequence
  #   1
  #   noeval
  #     true
  #     [ 1, 2, 3 ]
  #   # f.ret is still 1 here, not [ 1, 2, 3 ]
  # ```

  name 'noeval'

  def execute

    wrap
  end
end

