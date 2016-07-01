#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
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


class Flor::Pro::Concurrence < Flor::Procedure

  name 'concurrence'

  def pre_execute

    @node['atts'] = []
    #@node['payload'] = Flor.dup(payload)
  end

  def receive_last_att

    return reply unless children[@ncid]

    (@ncid..children.size - 1)
      .map { |i| execute_child(i, 0, true) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children
  end

  def receive_non_att

    @node['receiver'] ||= determine_receiver
    @node['merger'] ||= determine_merger

    (@node['cnodes'] || []).delete(from)

    return [] if @node['over']

    over = invoke_receiver
      # true: the concurrence is over, false: the concurrence is still waiting

    return [] unless over

    @node['over'] = true

    pld = invoke_merger
      # determine post-concurrence payload

    cancel_remaining +
    reply('payload' => pld)
  end

  protected

  def determine_receiver

    ex = att(:expect)

    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0

    'default_receive'
  end

  def determine_merger

    'default_merge'
  end

  def cancel_remaining

    # remaining:
    # * 'cancel' (default)
    # * 'forget'
    # * 'wait'

    rem = att(:remaining, :rem)

    return [] if rem == 'forget'

    cancel_nodes(@node['cnodes'])
  end

  def invoke_receiver

    # TODO: receiver function case

    self.send(@node['receiver'])
  end

  def invoke_merger

    # TODO: merger function case

    self.send(@node['merger'])
  end

  def store_payload

    (@node['payloads'] ||= {})[@message['from']] =
      Flor::Ash.deflate(@excution, payload)
  end

  def default_receive

    store_payload

    @node['payloads'].size >= non_att_children.size
  end

  def expect_integer_receive

    store_payload

    @node['payloads'].size >= att(:expect)
  end

  def default_merge

    @node['payloads'].values
      .reverse
      .inject({}) { |h, pl| h.merge!(Flor::Ash.copy(@execution, pl)) }
  end
end

