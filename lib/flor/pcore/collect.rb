
class Flor::Pro::Collect < Flor::Macro

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

