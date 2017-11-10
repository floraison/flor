
require 'flor/pcore/iterator'


class Flor::Pro::Filter < Flor::Pro::Iterator
  #
  # Filters a collection
  #
  # ```
  # filter [ 1, 2, 3, 4, 5 ]
  #   def x
  #     = (x % 2) 1
  #
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## with objects (hashes)
  #
  # ```
  # filter { a: 'A', b: 'B', c: 'C', d: 'D' }
  #   def k v i
  #     #or (k == 'a') (v == 'C') (i == 3)
  #     k == 'a' or v == 'C' or i == 3
  #
  # # f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
  # ```
  #
  # ## filter-out
  #
  # Is the negative sibling of "filter".
  #
  # ```
  # filter-out [ 1, 2, 3, 4, 5 ]
  #   def x
  #     = (x % 2) 0
  #
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## see also
  #
  # map, select, and reject.

  names %w[ filter filter-out ]

  def pre_iterations

    @node['res'] = []
  end

  def receive_iteration

    @node['res'] << @node['col'][@node['idx']] \
      if (
        (heap == 'filter' && Flor.true?(payload['ret'])) ||
        (heap == 'filter-out' && Flor.false?(payload['ret'])))
  end

  def end_iterations

    ret =
      if @node['ocol'].is_a?(Hash)
        Hash[@node['res']]
      else
        @node['res']
      end

    wrap_reply('ret' => ret)
  end
end

