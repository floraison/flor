
class Flor::Pro::SortBy < Flor::Pro::Iterator

  name 'sort_by'

  protected

  def receive_iteration

    @node['res'] << payload['ret']
  end

  def iterator_result

    res = @node['res']
    res = res.collect(&:to_s) if res.collect(&:class).uniq.count > 1

    res.zip(@node['ocol'])
      .sort_by(&:first)
      .collect(&:last)
  end
end

