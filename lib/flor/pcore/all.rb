
require 'flor/pcore/iterator'


class Flor::Pro::All < Flor::Pro::Iterator
  #
  # Returns true if all the elements in a collection return true
  # for the given function.
  #
  # ```
  # all? [ 1, 2, 3 ]
  #   def elt \ elt > 0
  #     #
  #     # yields true
  #
  # all? [ 1, 2, 3 ]
  #   def elt \ elt > 2
  #     #
  #     # yields false
  # ```
  #
  # ```
  # all? { a: 'A', b: 'B' }
  #   def key, val \ val == 'A' or val == 'B'
  #     #
  #     # yields true
  # ```
  #
  # ### without a function
  #
  # For an array, yields true if all the elements are "trueish" (not nil,
  # not false).
  #
  # ```
  # all? []                            # yields true
  # all? [ 1 2 3 ]                     # yields true
  # all? [ 1 false 3 ]                 # yields false
  # ```
  #
  # For an object, yields true if all the values are trueish.
  #
  # ```
  # all? {}                            # yields true
  # all? { a: 'A', b: 'B', c: 'C' }    # yields true
  # all? { a: 'A', f: false, c: 'C' }  # yields false
  # ```
  #
  # ## incoming ret
  #
  # ```
  # []
  # all?  # yields true
  # [ 1 2 3 ]
  # all?  # yields true
  # [ 1 false 3 ]
  # all?  # yields false
  # ```
  #
  # ## iterating and functions
  #
  # Iterating functions accept 0 to 3 arguments when iterating over an
  # array and 0 to 4 arguments when iterating over an object.
  #
  # Those arguments are `[ value, index, length ]` for arrays.
  # They are `[ key, value, index, length ]` for objects.
  #
  # The corresponding `key`, `val`, `idx` and `len` variables are also
  # set in the closure for the function call.
  #
  # ## see also
  #
  # Any?

  name 'all?'

  protected

  def receive_iteration

    # nothing to do
  end

  def function_mandatory?

    false
  end

  def no_iterate

    ret =
      case col = @node['ocol']
      when Array then col.all?
      when Hash then col.values.all?
      else false
      end

    wrap_reply('ret' => ret)
  end

  def iterator_over?

    super ||
    (@node['idx'] > 0 && ( ! Flor.true?(payload['ret'])))
  end

  def iterator_result

    Flor.true?(payload['ret'])
  end
end

