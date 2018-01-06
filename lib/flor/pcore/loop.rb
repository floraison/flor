
class Flor::Pro::Loop < Flor::Pro::Cursor
  #
  # Executes child expressions in sequence, then loops around.
  #
  # It's mostly a [cursor](cursor.md) that loops upon going past its
  # last child.
  #
  # ```
  # loop
  #   task 'alpha'
  #   task 'bravo'
  # ```
  #
  # Accepts `break` and `continue` like `cursor` does.
  #
  # ## see also
  #
  # Cursor, break, continue.

  name 'loop'

  def receive_non_att

    if @ncid >= children.size
      @node['subs'] << counter_next('subs')
      execute_child(first_non_att_child_id, @node['subs'].last)
    else
      execute_child(@ncid, @node['subs'].last)
    end
  end
end

