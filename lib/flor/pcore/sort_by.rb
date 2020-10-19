# frozen_string_literal: true

class Flor::Pro::SortBy < Flor::Pro::Iterator
  #
  # Takes a collection and a function and returns the collection
  # sorted by the value returned by the function.
  #
  # ```
  # sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ] (def e \ e.n)
  #   # OR
  # sort_by (def e \ e.n) [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
  #   #
  #   # => [ { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ]
  # ```
  #
  # ## function parameters
  #
  # If the collection is an array, the function signature may look like:
  # ```
  # def f(elt, idx, len)
  #   # elt: the element
  #   # idx: the index of the element (an integer starting at 0)
  #   # len: the length of the array being sorted
  # ```
  # If the collection is an object:
  # ```
  # def f(key, val, idx, len)
  #   # key: the key for the entry
  #   # val: the value for the entry
  #   # idx: the index of the entry (an integer starting at 0)
  #   # len: the number of keys/entries in the object
  # ```
  #
  # Once the function has returning what value to rank/sort by, the
  # sorting is done behind the scene by a (Ruby) sort. If the
  # values returned are heterogeneous, the values are turned into
  # their JSON representation before the sorting happens.
  #
  # ## see also
  #
  # sort, reverse, and shuffle

  name 'sort_by'

  protected

  def receive_iteration

    @node['res'] << payload['ret']
  end

  def iterator_result

    res = @node['res']

    classes = res.collect(&:class).uniq

    res = res.collect { |e| e.is_a?(String) ? e : JSON.dump(e) } \
      if classes.count > 1 || [ Hash ].include?(classes[0])

    r = res.zip(@node['ocol'])
      .sort_by(&:first)
      .collect(&:last)

    @node['ocol'].is_a?(Hash) ? Hash[r] : r
  end
end

