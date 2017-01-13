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

    @node['subs'] = []
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
        @node['subs'] << counter_next('subs')
        execute_child(first_non_att_child_id, @node['subs'].last)
      else
        reply
      end
    else
      execute_child(@ncid, @node['subs'].last)
    end
  end

  def cancel_when_closed

    return [] unless @message['flavour'] == 'break'

    cancel
  end

  def cancel

    fla = @message['flavour']

#    busy = @node['on_receive_last']
#
#    close_node
#
#    @node['on_receive_last'] =
#      if fla == 'continue'
#        @node['subs'] << counter_next('subs')
#        execute_child(first_non_att_child_id, @node['subs'].last, 'orl' => fla)
#      elsif fla == 'move'
#        @node['subs'] << counter_next('subs')
#        execute_child(move_target_child_id, @node['subs'].last, 'orl' => fla)
#      else # 'break'
#        nil
#      end
#
#    return [] if busy
#      # <------- that implies that upon a sound reply,
#      #          @node['on_receive_last'] is set to nil!
#      #          @node['status'] is cleaned...
#
#    super.tap { |ms| pp ms }

#if nid == '0_1_0'
#  puts "\\" * 80
#  puts caller[0, 7]
#end

    if fla == 'continue'

      @node['on_receive_last'] =
        reply(
          'nid' => nid, 'from' => "#{nid}_#{children.size + 1}",
          'orl' => fla,
          'payload' => Flor.dup(message['payload']))

    elsif fla == 'move'

      @node['subs'] << counter_next('subs')

      @node['on_receive_last'] =
        execute_child(move_target_child_id, @node['subs'].last, 'orl' => fla)

    else

      @node['on_receive_last'] = nil
    end

    super#.tap { |ms| pp ms }
  end

  protected

  def move_target_child_id

    to = @message['to']

    fail("move target #{to.inspect} is not a string") unless to.is_a?(String)

    find_tag_target(to) ||
    find_string_arg_target(to) ||
    find_string_target(to) ||
    find_name_target(to) ||
    find_att_target(to) ||
    fail("move target #{to.inspect} not found")
  end

  def find_tag_target(to)

    tree[1]
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
  end

  def find_string_arg_target(to)

    tree[1]
      .index { |c|
        c[1].is_a?(Array) &&
        c[1].index { |cc|
          Flor.is_tree?(cc) &&
          cc[0] == '_att' &&
          cc[1].size == 1 &&
          %w[ _sqs _dqs ].include?(cc[1][0][0]) &&
          cc[1][0][1] == to
        }
      }
  end

  def find_string_target(to)

    tree[1].index { |c| %w[ _sqs _dqs ].include?(c[0]) && c[1] == to }
  end

  def find_name_target(to)

    tree[1].index { |c| c[0] == to }
  end

  def find_att_target(to)

    tree[1]
      .index { |c|
        c[0] == '_' &&
        c[1].is_a?(Array) &&
        c[1].find { |cc|
          cc[0] == '_att' &&
          cc[1].is_a?(Array) &&
          cc[1][0][0, 2] == [ 'here', [] ]
        }
      }
  end
end

