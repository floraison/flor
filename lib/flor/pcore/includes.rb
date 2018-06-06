
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
      if col == nil && (ret.is_a?(Array) || ret.is_a?(Hash))
        col = ret
      elsif elt == :nil
        elt = ret
      end
    end

    fail Flor::FlorError.new('missing collection', self) if col == nil
    fail Flor::FlorError.new('missing element', self) if elt == :nil

    wrap_reply('ret' => col.include?(elt))
  end
end

