
class Flor::Pro::OnError < Flor::Procedure

  name 'on_error'

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    on_error = (@node['rets'] || [])
      .find { |o| Flor.is_proc_tree?(o) || Flor.is_func_tree?(o) }
    store_on_error(on_error) if on_error

    super
  end
end

