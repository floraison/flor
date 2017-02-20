
class Flor::Pro::Sequence < Flor::Procedure
  #
  # Executes child expressions in sequence.
  #
  # ```
  # sequence
  #   task 'alpha'
  #   task 'bravo' if f.amount > 2000
  #   task 'charly'
  # ```

  names %w[ sequence _apply begin ]
end

