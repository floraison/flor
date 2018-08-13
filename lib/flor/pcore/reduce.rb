
class Flor::Pro::Reduce < Flor::Pro::Iterator
  #
  # Reduce takes a collection and a function. It reduces the collection
  # to a single result thanks to the function.
  #
  # ```
  # reduce [ '0', 1, 'b', 3 ]
  #   def result element
  #     result + element
  # # --> "01b3"
  # ```
  #
  # An initial value is accepted (generally after the collection)
  #
  # ```
  # reduce [ 0, 1, 2, 3, 4 ] 10
  #   def result i \ result + i
  # # --> 20
  # ```
  #
  # Passing a proc is OK too, but, in the case of a mathematical expression
  # prefixing it with `v.` prevents premature rewriting...
  #
  # ```
  # reduce [ 0, 1, 2, 3, 4 ] 10 v.+
  # # --> 20
  # ```
  #
  # ## iterating and functions
  #
  # Iterating functions accept 0 to 3 arguments when iterating over an
  # array and 0 to 4 arguments when iterating over an object.
  #
  # Those arguments are `[ result, value, index, length ]` for arrays.
  # They are `[ result, key, value, index, length ]` for objects.
  #
  # The corresponding `res`, `key`, `val`, `idx` and `len` variables are also
  # set in the closure for the function call.
  #
  # ## see also
  #
  # Inject.

  name 'reduce'

  protected

  def prepare_iterations

    @node['args']
      .each { |a|
        if Flor.is_func_tree?(a)
          @node['fun'] ||= a
        elsif Flor.is_proc_tree?(a)
          @node['fun'] ||= proc_to_fun(a)
        elsif Flor.is_collection?(a)
          @node['ocol'] ||= a
        else
          @node['res'] ||= a
        end }

    @node['ocol'] ||= node_payload_ret
    ocol = @node['ocol']

    fail Flor::FlorError.new(
      "function not given to #{heap.inspect}", self
    ) unless @node['fun']
    fail Flor::FlorError.new(
      "collection not given to #{heap.inspect}", self
    ) unless Flor.is_collection?(ocol)

    @node['col'] = Flor.to_coll(@node['ocol'])

    @node['res'] ||= @node['col'].shift

    @node['args'] = nil
  end

  def determine_iteration_vars

    res = @node['res']
    idx = @node['idx']
    elt = @node['col'][idx]
    len = @node['col'].length

    if @node['ocol'].is_a?(Array)
      { 'res' => res, 'elt' => elt,
        'idx' => idx, 'len' => len }
    else
      { 'res' => res, 'key' => elt[0], 'val' => elt[1],
        'idx' => idx, 'len' => len }
    end
  end

  def receive_iteration

    @node['res'] = payload['ret']
  end

  def iterator_result

    @node['res']
  end

  def proc_to_fun(prc)

    h = prc[1]['proc']
    l = tree[2]

    [ '_func',
      { 'nid' => "#{nid}_0_1",
        'tree' =>
          [ 'def', [
            [  '_att', [ [ 'r', [], l ] ], l ],
            [  '_att', [ [ 'x', [], l ] ], l ],
            [  h, [ [ 'r', [], l ], [ 'x', [], l ] ], l ]
          ], l ],
        'cnid' => '0',  #
        'fun' => 0 },   # TODO really?
      l ]
  end
end

