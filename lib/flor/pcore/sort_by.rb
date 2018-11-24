
class Flor::Pro::SortBy < Flor::Pro::Iterator

  name 'sort_by'

  protected

  def receive_iteration

    @node['res'] << payload['ret']
  end

  def iterator_result

    @node['res'].zip(@node['ocol'])
      .sort_by(&:first)
      .collect(&:last)
  end
end

