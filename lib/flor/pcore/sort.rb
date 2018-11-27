
class Flor::Pro::Sort < Flor::Procedure

  name 'sort'

  def pre_execute

    @node['ocol'] = nil # collection
    @node['fun'] = nil # function

    unatt_unkeyed_children
  end

  def receive_non_att

    r = payload['ret']

    if Flor.is_func_tree?(r)
      @node['fun'] ||= r
    elsif Flor.is_collection?(r)
      @node['ocol'] ||= r
    end

    super
  end

  def receive_last

    wrap('ret' => simple_sort)
  end

  protected

  def receive_argument

    @node['args'] << payload['ret']

    if children[@ncid]
      execute_child(@ncid)
    else
      iterate
    end
  end

  def simple_sort

    col =
      @node['ocol']
    classes =
      col.collect(&:class).uniq
    f =
      (classes.count > 1 || [ Hash ].include?(classes[0])) ?
      lambda { |e| e.is_a?(String) ? e : JSON.dump(e) } :
      lambda { |e| e }

    col.sort_by(&f)
  end
end

