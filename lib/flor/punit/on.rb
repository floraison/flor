
class Flor::Pro::On < Flor::Macro
  #
  # Traps a signal by name
  #
  # Turns
  # ```
  # on 'approve'
  #   task 'bob' mission: 'gather signatures'
  # ```
  # into
  # ```
  # trap point: 'signal', name: 'approve'
  #   set sig 'signal'
  #   def msg
  #     task 'bob' mission: 'gather signatures'
  # ```

  name 'on'

  def rewrite_tree

    atts = att_children
    signame_i = atts.index { |at| at[1].size == 1 }

    fail Flor::FlorError.new("signal name not found in #{tree.inspect}", self) \
      unless signame_i

    tname = atts[signame_i]
    tname = Flor.dup(tname[1][0])
    atts.delete_at(signame_i)

    l = tree[2]

    th = [ 'trap', [], l, *tree[3] ]
    th[1] << [ '_att', [ [ 'point', [], l ], [ '_sqs', 'signal', l ] ], l ]
    th[1] << [ '_att', [ [ 'name', [], l ], tname ], l ]
    th[1] << [ '_att', [ [ 'payload', [], l ], [ '_sqs', 'event', l ] ], l ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    th[1] << [ 'set', [
      [ '_att', [ [ 'sig', [], l ] ], l ],
      tname
    ], l ]

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

