
class Flor::Pro::Every < Flor::Macro

  name 'every'

  def rewrite_tree

    l = tree[2]

    th = [ 'schedule', [], l, *tree[3] ]
    att_children.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

