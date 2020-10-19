# frozen_string_literal: true

class Flor::Pro::Ccollect < Flor::Macro::Iterator
  #
  # A concurrent version of [collect](collect.md).
  #
  # Whereas "collect" executes its children one by one and then yields
  # an array with the result of each child, "ccollect" executes the children
  # concurrently.
  #
  # In the example below, Alice, Bob, and Charly are concurrently tasked
  # with some analysis work. The field `ret` coming out of the "ccollect"
  # will be an array composed of the `f.ret` of each "task" call.
  # ```
  # sequence
  #   ccollect [ 'alice' 'bob' 'charly' ]
  #     notify elt 'you received a task'
  #     task elt "initiate analysis for project $(project.id) as #$(idx + 1)"
  # ```
  #
  # Like "collect", the block iterating over an array will receive the `elt`,
  # `idx` and `len` variables (current element, current element index (starting
  # at zero), and length of the collection).
  #
  # When iterating over an object (a hash), the variables will be `key`, `val`,
  # `idx`, and `len`.
  #
  # "ccollect" is actually a macro rewriting itself to a [cmap](cmap.md).
  #
  # ## see also
  #
  # Collect, map, c-map.

  names %w[ ccollect c-collect ]

  def rewrite_tree

    rewrite_iterator_tree('cmap')
  end
end

