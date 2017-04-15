
class Flor::Pro::Task < Flor::Procedure

  name 'task'

  def pre_execute

    @node['atts'] = []
  end

  def receive

    return wrap_reply('payload' => determine_reply_payload) \
      if point == 'receive' && from == nil

    super
      # which goes to #receive or #receive_when_status
  end

  alias receive_when_closed receive_from_child_when_closed

  def receive_last_att

    # task 'clean up' by: 'alan'
    # task 'clean up' for: 'alan'
    # task 'clean up' assign: 'alan'
    # task 'alan' with: 'clean up'
    # clean_up assign: 'alan'
    # "clean up" assign: 'alan'
    # alan task: 'clean up'

    ni = att(nil)
    ta = att('by', 'for', 'assign')
    tn = att('with', 'task')

    tasker = ta || ni

    taskname = tn || ni
    taskname = nil if ta == nil && tasker == ni

    attl, attd = determine_atts

    wrap(
      'point' => 'task',
      'exid' => exid, 'nid' => nid,
      'tasker' => tasker,
      'taskname' => taskname,
      'attl' => attl, 'attd' => attd,
      'payload' => determine_payload)
#.tap { |x| pp x.first }
  end

  def cancel

    close_node

    attl, attd = determine_atts

    wrap(
      'point' => 'detask',
      'exid' => exid, 'nid' => nid,
      'tasker' => att(nil),
      'attl' => attl, 'attd' => attd,
      'payload' => determine_payload)
  end

  protected

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

