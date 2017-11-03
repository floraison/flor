
require 'flor/pcore/iterator'


class Flor::Pro::Filter < Flor::Pro::Iterator
  #
  # Filters a collection
  # ```
  # filter [ 1, 2, 3, 4, 5 ]
  #   def x
  #     = (x % 2) 1
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## see also
  #
  # Map and select.

  name 'filter'

  def pre_iterations

    @node['res'] = []
  end

  def receive_iteration

    @node['res'] << @node['col'][@node['idx']] if Flor.true?(payload['ret'])
  end

  def end_iterations

    wrap_reply('ret' => @node['res'])
  end
end

