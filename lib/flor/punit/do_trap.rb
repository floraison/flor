# frozen_string_literal: true

class Flor::Pro::DoTrap < Flor::Macro
  #
  # A version of trap that accepts a block instead of a function.
  #
  # do-trap accepts the same attributes as [trap][trap.md] does.
  #
  # ```
  # sequence
  #   do-trap 'terminated'
  #     trace "terminated(f:$(msg.from))"
  #   trace "here($(nid))"
  # ```
  # which traces to:
  # ```
  # here(0_1_0_0)
  # terminated(f:0)
  # ```
  #
  # ## see also
  #
  # Trap, on, signal.

  name 'do-trap'

  def rewrite_tree

    l = tree[2]

    th = [ 'trap', [], l, *tree[3] ]
    att_children.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

