
class Flor::Pro::SortBy < Flor::Pro::Iterator

  name 'sort_by'

  protected

  def receive_iteration

    @node['res'] << payload['ret']
  end

  def iterator_result

    res = @node['res']

    classes = res.collect(&:class).uniq

    res = res.collect { |e| e.is_a?(String) ? e : JSON.dump(e) } \
      if classes.count > 1 || [ Hash ].include?(classes[0])

    res.zip(@node['ocol'])
      .sort_by(&:first)
      .collect(&:last)
  end
end

