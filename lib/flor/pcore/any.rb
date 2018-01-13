
require 'flor/pcore/find'


class Flor::Pro::Any < Flor::Pro::Find
  #
  # Returns `true` if at least one of the member of a collection returns
  # something trueish for the given function. Returns `false` else.
  #
  # ```
  # any? [ 1, 2, 3 ]
  #   def elt
  #     (elt % 2) == 0
  # # yields `true` thanks to element `2`
  # ```
  #
  # ```
  # any? { a: 'A', b: 'B', c: 'C' }
  #   def key, val \ val == 'B'
  # # yields `true` thanks to entry { b: 'B' }
  # ```
  #
  #
  # ## see also
  #
  # Find, every?.

  name 'any?'

  protected

  def iterator_result

    super != nil
  end
end

