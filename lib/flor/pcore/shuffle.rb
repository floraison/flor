
class Flor::Pro::Shuffle < Flor::Procedure

  names %w[ shuffle ]

  def receive

    ret = payload['ret']
    @node['arr'] = ret if ret.is_a?(Array)

    super
  end

  def receive_last

    arr = @node['arr']

    fail Flor::FlorError.new("no array to #{@node['heat0']}") unless arr

    ret = arr.shuffle

    wrap('ret' => arr.shuffle)
  end
end

