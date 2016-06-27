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


class Flor::Ash

  FUN = 'SHA256'

  def self.digest(execution, msgs)

    msgs.each do |m|

      pl = m['payload']
      vs = m['vars']

      if pl.class != String && pl.class != NilClass
        m['payload'] = do_digest(execution, pl)
      end
      if vs.class != String && vs.class != NilClass
        m['vars'] = do_digest(execution, vs)
      end
    end
  end

  def self.do_digest(execution, hash)

    return hash.code if hash.is_a?(Flor::Ash)

    afun = Digest.const_get(FUN)
    code = "#{FUN}:#{afun.hexdigest(JSON.dump(hash))}"

    execution['ashes'][code] = hash

    code
  end

  attr_reader :code

  def initialize(execution, message, key)

    @execution = execution
    @message = message
    @key = key

    x = message[key]
    @code, @val = x.is_a?(String) ? [ x, nil ] : [ nil, x ]
  end

  def []=(k, v)

    @val ||= Flor.dup(@execution['ashes'][@code])

    @code = nil
    @val[k] = v
  end

  def [](k)

    (@val ? @val : @execution['ashes'][@code])[k]
  end

  #def to_json(*states)
  #  if @val
  #    @code = do_digest(@execution, @val)
  #    @val = nil
  #  end
  #  @code.inspect
  #end
end

