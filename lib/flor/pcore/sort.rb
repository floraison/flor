
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

    wrap('ret' => @node['ocol'].sort)
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
end

