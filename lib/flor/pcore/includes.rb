
class Flor::Pro::Includes < Flor::Procedure

  name 'includes?'

  def pre_execute

    @node['rets'] = []

    unatt_unkeyed_children
  end

  def receive_last

    col = nil
    elt = :nil

    @node['rets'].each do |ret|
      if col == nil && Flor.is_collection?(ret)
        col = ret
      elsif elt == :nil
        elt = ret
      end
    end

    ret = (col == nil) && node_payload_ret
    col = ret if Flor.is_collection?(ret)

    fail Flor::FlorError.new('missing collection', self) if col == nil
    fail Flor::FlorError.new('missing element', self) if elt == :nil

    wrap('ret' => col.include?(elt))
  end
end

