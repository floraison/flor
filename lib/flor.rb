
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

#require 'json'
#require 'thread'
#require 'logger'

require 'munemo'


module Flor

  VERSION = '0.4.0'
end

require 'flor/parsers'
require 'flor/instruction'
require 'flor/executor'


module Flor

  def self.dup(o)

    Marshal.load(Marshal.dump(o))
  end

  def self.tstamp(t=Time.now.utc)

    t.strftime('%Y%m%d.%H%M%S') + sprintf('%06d', t.usec)
  end

  def self.to_error(o)

    if o.respond_to?(:message)
      { 'msg' => o.message,
        'kla' => o.class.to_s,
        'trc' => o.backtrace[0, 7] }
    else
      { 'msg' => o.to_s }
    end
  end

  def self.to_index(s)

    return 0 if s == 'first'
    return -1 if s == 'last'

    i = s.to_i
    return nil if i.to_s != s

    i
  end

  def self.deep_get(o, k) # --> success(boolean), value

    return [ true, o ] unless k

    val = o
    ks = k.split('.')

    loop do

      break unless kk = ks.shift

      case val
        when Array
          i = to_index(kk)
          return [ false, nil ] unless i
          val = val[i]
        when Hash
          val = val[kk]
        else
          return [ false, nil ]
      end
    end

    [ true, val ]
  end

  def self.deep_set(o, k, v) # --> [ success(boolean), value ]

    lastdot = k.rindex('.')
    path = lastdot && k[0..lastdot - 1]
    key = lastdot ? k[lastdot + 1..-1] : k

    b, col = deep_get(o, path)

    return [ false, v ] unless b

    case col
      when Array
        i = to_index(key)
        return [ false, v ] unless i
        col[i] = v
      when Hash
        col[key] = v
      else
        return [ false, v ]
    end

    [ true, v ]
  end
end

Dir[File.join(File.dirname(__FILE__), 'flor/n/*.rb')].each do |path|
  require path
end

