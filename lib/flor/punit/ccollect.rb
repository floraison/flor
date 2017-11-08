
class Flor::Pro::Ccollect < Flor::Macro

  name 'ccollect'

  def rewrite_tree

    atts = att_children

    l = tree[2]

    th = [ 'cmap', [], l, *tree[3] ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    if non_att_children.any?

      td = [ 'def', [], l ]
      td[1] << [ '_att', [ [ 'elt', [], l ] ], l ]
      non_att_children.each { |nac| td[1] << Flor.dup(nac) }

      th[1] << td
    end

    th
  end
end

