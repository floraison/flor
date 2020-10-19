# frozen_string_literal: true

class Flor::Pro::On < Flor::Macro
  #
  # Catches signals or errors.
  #
  # ## signals
  #
  # Turns
  # ```
  # on 'approve'
  #   task 'bob' mission: 'gather signatures'
  # ```
  # into
  # ```
  # trap point: 'signal', name: 'approve'
  #   def msg
  #     task 'bob' mission: 'gather signatures'
  # ```
  #
  # It's OK trapping multiple signal names:
  # ```
  # on [ /^bl/ 'red' 'white' ]
  #   task 'bob' mission: "order can of $(sig) paint"
  # ```
  #
  # ## error
  #
  # "on" understands `on error` with a block. It in facts turns:
  # ```
  # sequence
  #   on error
  #     push f.l err.msg # a block with an `err` variable
  #   # ...
  # ```
  # into:
  # ```
  # sequence
  #   on_error
  #     def err # a anonymous function definition with an `err` argument
  #       push f.l err.msg
  #   # ...
  # ```
  #
  # Please note that "error" in `on error` is not quoted, nor double quoted.
  # If it were, it would trap the signal named "error".
  #
  # `on error` accepts the same criteria as [on_error](on_error.md), as in:
  # ```
  # sequence
  #   on error (/timeout/)
  #     charly "it timed out"
  #   on error
  #     charly "it failed", err
  #   alice 'do this'
  #   bob 'do that'
  # ```
  #
  #
  # ## cancel
  #
  # "on" understands `on cancel` with a block. It in facts turns:
  # ```
  # sequence
  #   on cancel
  #     push f.l msg # a block with a `msg` variable
  #   # ...
  # ```
  # into:
  # ```
  # sequence
  #   on_cancel
  #     def msg # a anonymous function definition with a `msg` argument
  #       push f.l msg
  #   # ...
  # ```
  #
  # Please note that "cancel" in `on cancel` is not quoted, nor double quoted.
  # If it were, it would trap the signal named "cancel".
  #
  #
  # ## timeout
  #
  # `on timeout` turns:
  # ```
  # sequence timeout: '1w'
  #   on timeout
  #     push f.l msg # a block with a `msg` variable
  #   # ...
  # ```
  # into:
  # ```
  # sequence timeout: '1w'
  #   on_timeout
  #     def msg # a anonymous function definition with a `msg` argument
  #       push f.l msg
  #   # ...
  # ```
  #
  # Please note that "timeout" in `on timeout` is not quoted, nor double quoted.
  # If it were, it would trap the signal named "timeout".
  #
  #
  # ## blocking mode
  #
  # When "on" is given no code block, it will block.
  # ```
  # sequence
  #   # ...
  #   on 'green'  # execution (branch) blocks here until signal 'green' comes
  #   # ...
  # ```
  #
  # Behind the scenes, it simply rewrites the "on" to a "trap" without a
  # function, a blocking trap.
  #
  #
  # ## see also
  #
  # Trap and signal.

  name 'on'

  def rewrite_tree

    if att = find_catch # 22
      rewrite_as_catch_tree(att)
    else
      rewrite_as_signal_trap_tree
    end
  end

  protected

  CATCHES = %w[ error cancel timeout ].freeze

  def find_catch

    att_children
      .each_with_index { |t, i|
        tt = t[1].is_a?(Array) && t[1].length == 1 && t[1].first
        return [ tt[0], i ] if tt && tt[1] == [] && CATCHES.include?(tt[0]) }

    nil
  end

  def rewrite_as_catch_tree(att)

    flavour, index = att

    atts = att_children
    atts.delete_at(index)

    l = tree[2]

    th = [ "on_#{flavour}", [], l, *tree[3] ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    td[1] << [ '_att', [ [ 'err', [], l ] ], l ] if flavour == 'error'
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end

  def rewrite_as_signal_trap_tree

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

    att_names = []
    atts.each { |at|
      att_names << at[1][0][0]
      th[1] << Flor.dup(at) }

    th[1] << [ '_att', [ [ 'payload', [], l ], [ '_sqs', 'event', l ] ], l ] \
      unless att_names.include?('payload')

    if (nac = non_att_children).any?

      td = [ 'def', [], l ]
      td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
      non_att_children.each { |nac| td[1] << Flor.dup(nac) }

      th[1] << td
    end

    th
  end
end

