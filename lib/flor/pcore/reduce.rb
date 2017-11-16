
class Flor::Pro::Reduce < Flor::Pro::Iterator

  name 'reduce'

  def pre_iterator

    # nothing to do
@node['res'] = ''
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
end

