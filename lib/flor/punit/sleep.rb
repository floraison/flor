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


class Flor::Pro::Sleep < Flor::Procedure
  #
  # Makes a branch of an execution sleep for a while.
  #
  # ```
  # sleep '1y'       # sleep for one year
  # sleep for: '2y'  # sleep for two years, with an explicit for:
  # sleep '2d1m10s'  # sleep for two days, one minute and ten seconds
  # ```

  name 'sleep'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    t = att('for', nil)
    fail ArgumentError.new("missing a sleep time duration") unless t

    m = reply('point' => 'receive').first

    schedule('type' => 'in', 's' => t, 'message' => m)
  end
end

