
require 'flor/pcore/iterator'


class Flor::Pro::ForEach < Flor::Pro::Iterator

  name 'for-each'

  def pre_iterations

    # nothing to do
  end

  def receive_iteration

    # nothing to do
  end

  def end_iterations

    wrap_reply('ret' => @node['col'])
  end
end

