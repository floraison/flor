
class Flor::Pro::Ceach < Flor::Macro::Iterator
  #
  # Concurrent "each".
  #
  # ```
  # ceach [ alice bob charly ]
  #   task elt "prepare monthly report"
  # ```
  # which is equivalent to
  # ```
  # concurrence
  #   task 'alice' "prepare monthly report"
  #   task 'bob' "prepare monthly report"
  #   task 'charly' "prepare monthly report"
  # ```
  #
  # ## see also
  #
  # For-each, c_map, and c_each.

  names %w[ ceach c-each ]

  def rewrite_tree

    rewrite_iterator_tree('c-for-each')
  end
end

