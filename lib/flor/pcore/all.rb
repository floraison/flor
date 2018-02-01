
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
  # ```
  # all? []                            # yields true
  # all? [ 1 2 3 ]                     # yields true
  # all? [ 1 false 3 ]                 # yields false
  # all? {}                            # yields true
  # all? { a: 'A', b: 'B', c: 'C' }    # yields true
  # all? { a: 'A', f: false, c: 'C' }  # yields false
  # ```
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

