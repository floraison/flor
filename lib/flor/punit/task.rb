#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


class Flor::Pro::Task < Flor::Procedure

  name 'task'

  def pre_execute

    @node['atts'] = []
  end

  def do_receive

    return reply('payload' => determine_reply_payload) \
      if point == 'receive' && from == nil

    super
      # which goes to #receive or #receive_when_status
  end

  def receive_last_att

    # task 'clean up' by: 'alan'
    # task 'clean up' for: 'alan'
    # task 'clean up' assign: 'alan'
    # task 'alan' with: 'clean up'
    # clean_up assign: 'alan'
    # "clean up" assign: 'alan'
    # alan task: 'clean up'

    #@executor.unit.has_tasker?(@executor.exid, key)

    ni = att(nil)
    ta = att('by', 'for', 'assign')
    tn = att('with', 'task')

    tasker = ta || ni

    taskname = tn || ni
    taskname = nil if ta == nil && tasker == ni

    attl, attd = determine_atts

    queue(
      'point' => 'task',
      'exid' => exid, 'nid' => nid,
      'tasker' => tasker,
      'taskname' => taskname,
      'attl' => attl, 'attd' => attd,
      'payload' => determine_payload)
#.tap { |x| pp x.first }
  end

  def cancel

    attl, attd = determine_atts

    queue(
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

