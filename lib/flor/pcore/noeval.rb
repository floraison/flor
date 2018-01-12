
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
  #
  # Could be useful when determining on the fly what the "parent"
  # procedure should be.
  # ```
  # set head
  #   case (size f.customers)
  #     0;          noeval
  #     [ 1, 10 ];  concurrence
  #     else;       sequence
  # head
  #   task 'a'
  #   task 'b'
  # ```

  name 'noeval'

  def execute

    wrap
  end
end

