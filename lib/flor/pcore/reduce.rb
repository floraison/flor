
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
        elsif a.is_a?(Array) || a.is_a?(Hash)
          @node['ocol'] ||= a
        else
          @node['res'] ||= a
        end }

    @node['ocol'] ||= node_payload_ret
    ocol = @node['ocol']

    fail Flor::FlorError.new(
      "Function not given to #{heap.inspect}", self
    ) unless @node['fun']
    fail Flor::FlorError.new(
      "Collection not given to #{heap.inspect}", self
    ) unless ocol.is_a?(Array) || ocol.is_a?(Hash)

    @node['col'] = Flor.to_coll(@node['ocol'])

    @node['res'] ||= @node['col'].shift

    @node['args'] = nil
  end

  def determine_iteration_vars

    idx = @node['idx']
    elt = @node['col'][idx]

    if @node['ocol'].is_a?(Array)
      { 'res' => @node['res'], 'elt' => elt, 'idx' => idx }
    else
      { 'res' => @node['res'], 'key' => elt[0], 'val' => elt[1], 'idx' => idx }
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

