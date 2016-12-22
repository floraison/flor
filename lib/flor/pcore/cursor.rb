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
  # ## break
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

  name 'cursor'

  def pre_execute

    @node['count'] = 0
  end

  def receive_first

    @node['vars'] =
      {}

    @node['vars']['break'] =
      [ '_proc', { '_proc' => 'break', 'nid' => nid }, tree[-1] ]
    @node['vars']['continue'] =
      [ '_proc', { '_proc' => 'continue', 'nid' => nid }, tree[-1] ]

    @node['vars']['move'] =
      [ '_proc', { '_proc' => 'move', 'nid' => nid }, tree[-1] ]

    super
  end

  def receive_att

    receive_unkeyed_tag_att + super
  end

  def receive_non_att

    if @ncid >= children.size
      if @message['orl'] == 'continue'
        execute_child(first_non_att_child_id, @node['count'] += 1)
      else
        reply
      end
    else
      execute_child(@ncid, @node['count'])
    end
  end

  def cancel

    fla = @message['flavour']

    if fla == 'continue'

      @node['status'] =
        'continued'
      @node['on_receive_last'] = [ {
        'point' => 'receive',
        'nid' => nid, 'from' => "#{nid}_#{children.size + 1}",
        'orl' => fla,
        'payload' => Flor.dup(message['payload'])
      } ]

    elsif fla == 'move'

      @node['status'] =
        'moved'
      @node['on_receive_last'] =
        execute_child(
          move_target_nid,
          @node['count'] += 1,
          false,
          { 'orl' => 'move' })

    else

      @node['status'] = fla == 'break' ? 'broken' : 'cancelled'
    end

    super
  end

  protected

  def move_target_nid

    to = @message['to']

    i = tree[1]
      .index { |c|
        c[1].is_a?(Array) &&
        c[1].index { |cc|
          Flor.is_tree?(cc) &&
          cc[0] == '_att' &&
          cc[1].size == 2 &&
          cc[1][0][0] == 'tag' &&
          %w[ _sqs _dqs ].include?(cc[1][1][0]) &&
          cc[1][1][1] == to
        }
      }

    fail(
      "move target #{to.inspect} not found"
    ) unless i

    i
  end
end

