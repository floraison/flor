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


class Flor::Pro::Schedule < Flor::Procedure
  #
  # Schedules a function
  #
  # ```
  # schedule cron: '0 0 1 jan *'  # every 1st day of the year, check systems
  #   def msg
  #     check_systems
  # ```
  #
  # See also: cron, at, in and sleep

  name 'schedule'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    fun = @fcid > 0 ? payload['ret'] : nil

    fail ArgumentError.new(
      "missing a function to call when the scheduler triggers"
    ) unless fun

    msg = apply(fun, [], tree[2], false).first.merge('noreply' => true)

    tstr = att('cron', 'at', 'in', 'every', nil)

    type = @node['atts']
      .collect(&:first)
      .find { |k| %w[ cron at in every ].include?(k) }

    fail ArgumentError.new(
      "missing a schedule"
    ) unless tstr

    #m = reply('point' => 'receive').first

    schedule('type' => type, 's' => tstr, 'message' => msg)
  end
end

