
class Flor::Pro::Collect < Flor::Macro
  #
  # Collect is a simplified version of [map](map.md).
  #
  # ```
  # map [ 1, 2, 3 ]
  #   def x
  #     + x 3
  #   #
  #   # becomes
  #   #
  # collect [ 1, 2, 3 ]
  #   + elt 3
  # ```
  # Collect accepts, instead of a function, a block, where `elt` contains
  # the current element and `idx` the current index.
  #
  # ```
  # collect [ 'a', 'b' ]
  #   [ idx, elt ]
  # ```
  #
  # ## see also
  #
  # Map.

  name 'collect'

  def rewrite_tree

    atts = att_children

    l = tree[2]

    th = [ 'map', [], l, *tree[3] ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'elt', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

