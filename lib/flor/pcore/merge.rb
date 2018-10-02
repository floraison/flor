
class Flor::Pro::Merge < Flor::Procedure

  name 'merge'

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    c0 = rets.find { |e| e.is_a?(Array) || e.is_a?(Hash) }

    fail Flor::FlorError.new('found no array or object to merge', self) \
      unless c0

    wrap('ret' => c0.is_a?(Array) ? merge_arrays : merge_objects)
  end

  protected

  def rets

    @rets ||= [ node_payload_ret ] + @node['rets']
  end

  def merge_arrays

    rets
      .select { |e| e.is_a?(Array) }
      .inject([]) { |r, a| a.each_with_index { |e, i| r[i] = e }; r }
  end

  def merge_objects

    rets
      .select { |e| e.is_a?(Hash) }
      .inject({}) { |r, h| r.merge(h) }
  end
end

