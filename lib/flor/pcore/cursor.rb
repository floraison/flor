
class Flor::Pro::Cursor < Flor::Procedure
  #
  # Executes child expressions in sequence, but may be "guided".
  #
  # ```
  # cursor
  #   task 'alpha'
  #   task 'bravo' if f.amount > 2000
  #   task 'charly'
  # ```
  #
  # ## "orders" understood by cursors
  #
  # ### break
  #
  # Cursor understands `break`. For example, this execution will go from
  # "alpha" to "charly", task "bravo" will not be visited.
  # ```
  # cursor
  #   task 'alpha'
  #   break _
  #   task 'bravo'
  # task 'charly'
  # ```
  #
  # ### continue
  #
  # Cursor also understands `continue`. It's useful to rewind a cursor:
  # ```
  # cursor
  #   sales_team "fill in customer details"
  #   ops_team "attribute account number"
  #   continue _ if f.ops_decision == 'reject'
  #   create_account _
  # ```
  #
  # ### move
  #
  # Cursor accepts move orders, as in:
  # ```
  # cursor
  #   do-this
  #   move to: 'do-that-other-thing'
  #   do-that _ # got skipped
  #   do-that-other-thing _
  # ```
  #
  # ## cursor and tags
  #
  # ```
  # cursor 'main'
  #   # is equivalent to
  # cursor tag: 'main'
  # ```
  #
  # Tags on cursors are useful for "break" and "continue" (as well as "cancel"),
  # letting them act on other cursors.
  #
  # ## see also
  #
  # Break, continue, loop.

  name 'cursor'

  def pre_execute

    @node['subs'] = []
  end

  def receive_first

    # break/continue/move are set as variables so that they can
    # be aliases, it's useful in nested loops

    @node['vars'] = {
      'break' =>
        [ '_proc', { 'proc' => 'break', 'nid' => nid }, tree[-1] ],
      'continue' =>
        [ '_proc', { 'proc' => 'continue', 'nid' => nid }, tree[-1] ],
      'move' =>
        [ '_proc', { 'proc' => 'move', 'nid' => nid }, tree[-1] ] }

    super
  end

  def receive_att

    receive_unkeyed_tag_att + super
  end

  def receive_non_att

    if @ncid >= children.size
      if @message['orl'] == 'continue'
        @node['subs'] << counter_next('subs')
        execute_child(first_non_att_child_id, @node['subs'].last)
      else
        wrap_reply
      end
    else
      execute_child(@ncid, @node['subs'].last)
    end
  end

  def cancel_when_closed

    return cancel if node_status_flavour == 'on-error'
    return [] if @message['flavour'] != 'break'

    cancel
  end

  def cancel

    if %w[ continue move ].include?(fla = @message['flavour'])

      cid =
        fla == 'move' ?
        move_target_child_id :
        first_non_att_child_id

      @node['subs'] <<
        counter_next('subs')

      @node['on_receive_last'] =
        execute_child(cid, @node['subs'].last, 'orl' => fla)

    else

      @node['on_receive_last'] = nil
    end

    super
  end

  protected

  def move_target_child_id

    to = @message['to']

    fail Flor::FlorError.new(
      "move target #{to.inspect} is not a string", self
    ) unless to.is_a?(String)

    find_tag_target(to) ||
    find_string_arg_target(to) ||
    find_string_target(to) ||
    find_name_target(to) ||
    find_att_target(to) ||
    fail(Flor::FlorError.new("move target #{to.inspect} not found", self))
  end

  def is_tag_tree?(t, tagname)

    Flor.is_att_tree?(t) &&
    t[1].size == 2 &&
    t[1][0][0, 2] == [ 'tag', [] ] &&
    Flor.is_string_tree?(t[1][1], tagname)
  end

  def is_att_string_tree?(t, s)

    Flor.is_att_tree?(t) &&
    t[1].size == 1 &&
    Flor.is_string_tree?(t[1].first, s)
  end

  def find_tag_target(to)

    tree[1]
      .index { |ct|
        ct[1].is_a?(Array) &&
        ct[1].index { |cc| is_tag_tree?(cc, to) } }
  end

  def find_string_arg_target(to)

    tree[1]
      .index { |c|
        c[1].is_a?(Array) &&
        c[1].index { |cc| is_att_string_tree?(cc, to) } }
  end

  def find_string_target(to)

    tree[1]
      .index { |ct| Flor.is_string_tree?(ct, to) }
  end

  def find_name_target(to)

    tree[1]
      .index { |ct| ct[0] == to }
  end

  def find_att_target(to)

    tree[1]
      .index { |c|
        c[0] == '_' &&
        c[1].is_a?(Array) &&
        c[1].find { |cc|
          cc[0] == '_att' &&
          cc[1].is_a?(Array) &&
          cc[1][0][0, 2] == [ 'here', [] ] } } # FIXME hardcoded...
  end
end

