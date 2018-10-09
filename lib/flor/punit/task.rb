
class Flor::Pro::Task < Flor::Procedure
  #
  # Tasks a tasker with a task.
  #
  # ```
  # task 'clean up' by: 'alan'
  # task 'clean up' for: 'alan'
  # task 'clean up' assign: 'alan'
  # task 'alan' with: 'clean up'
  # alan task: 'clean up'  # {tasker} task: {taskname}
  # task 'alan'
  # # ...
  # ```
  #
  # Note that the quotes are the tasker name can be omitted:
  # ```
  # task 'clean up' by: alan
  # task 'clean up' for: alan
  # task 'clean up' assign: alan
  # task alan with: 'clean up'
  # alan task: 'clean up'  # {tasker} task: {taskname}
  # task alan
  # # ...
  # ```
  #
  # Tasking hands a task (a message hash serializable to JSON) to a tasker.
  # See [tasks](../tasks.md) for more information.
  #
  # Since routing tasks among taskers is flor essential "task", this "task"
  # procedure is very important.
  #
  # Note that "task" can be implicit, as in:
  # ```
  # alan task: 'clean up'
  # ```

  name 'task'

  def pre_execute

    @node['atts'] = []
  end

  def receive

    return super if point != 'receive' || from != nil
      # which goes to #receive or #receive_when_status

    pl = determine_reply_payload
    #pl['ret'] = node_payload_ret
      # No, let's leave it at last f.ret wins...

    wrap_reply('payload' => pl)
      # "task" done, reply to parent node
  end

  alias receive_when_closed receive_from_child_when_closed

  def receive_last_att

    # task 'clean up' by: 'alan'
    # task 'clean up' for: 'alan'
    # task 'clean up' assign: 'alan'
    # task 'alan' with: 'clean up'
    # alan task: 'clean up'
      #
    # clean_up assign: 'alan'
    # "clean up" assign: 'alan'

    nis = atts(nil)
    ta = att('by', 'for', 'assign')
    tn = att('with', 'task')

    tasker = ta || nis.shift
    tasker = tasker[1]['tasker'] if Flor.is_tasker_tree?(tasker)
      #
    taskname = tn || nis.shift

    attl, attd = determine_atts

    @node['task'] =
      { 'tasker' => tasker, 'name' => taskname }

    wrap(
      'point' => 'task',
      'exid' => exid, 'nid' => nid,
      'tags' => list_tags,
      'tasker' => tasker,
      'taskname' => taskname,
      'attl' => attl, 'attd' => attd,
      'payload' => determine_payload)
  end

  def cancel

    close_node

    attl, attd = determine_atts

    wrap(
      'point' => 'detask',
      'exid' => exid, 'nid' => nid,
      'tags' => list_tags,
      'tasker' => att(nil),
      'attl' => attl, 'attd' => attd,
      'payload' => determine_payload)
  end

  protected

  # Returns an array attribute list / attribute dictionary.
  #
  def determine_atts

    attl, attd = [], {}
    @node['atts'].each { |k, v| if k.nil?; attl << v; else; attd[k] = v; end }

    [ attl, attd ]
  end

  def determine_payload

    message_or_node_payload.copy_current
  end

  def determine_reply_payload

    payload.copy_current
  end
end

