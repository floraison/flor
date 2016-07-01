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

  def initialize(execution, code)

    @execution = execution
    @code = code
  end

  def deflate

    return @code if @val.nil?

    @code = Flor::Ash.deflate(@execution, @val)
    @val = nil

    @code
  end

  def ref(key=nil)

    [ @code, key ].compact.join(':')
  end

  def copy

    return @val if @val

    @val = Flor.dup(@execution['ashes'][@code])
    @code = nil

    @val
  end

  def []=(k, v)

    copy[k] = v
  end

  def inflate

    @val || @execution['ashes'][@code]
  end

  def [](k)

    inflate[k]
  end

  def inspect

    "<#{self.class};@code=#{@code || 'nil'};@val=#{@val.inspect}>"
  end

  # class methods

  def self.deep_freeze(o)

    if o.is_a?(Array)
      o.each { |e| e.freeze }
    elsif o.is_a?(Hash)
      o.each { |k, v| k.freeze; v.freeze }
    end

    o.freeze
  end

  def self.deflate(execution, o, key=nil)

    val = key ? o[key] : o

    if val.nil? || val.is_a?(String)
      return
    end
    if val.is_a?(Flor::Ash)
      return key ? o[key] = val.ref : val.ref
    end

    code = "SHA256:#{Digest::SHA256.hexdigest(JSON.dump(val))}"
      #
    #code = "SHA256:#{Digest::SHA256.hexdigest(Marshal.dump(val))}"
      # potentially faster, but may vary from platform to plaftorm

    execution['ashes'][code] = deep_freeze(val)

    key ? (o[key] = code) : code
  end

  def self.deflate_all(a)

    Array(a).each do |h|

      h
        .select { |k, v| v.is_a?(Flor::Ash) }
        .each { |k, v|
          #h["_#{k}"] = v.ref
          h[k] = v.deflate }
    end
  end

  def self.inflate(execution, code)

    return code.inflate if code.is_a?(Flor::Ash)

    cs = code.split(':')
    c2 = cs[2]

    r = execution['ashes'][cs[0, 2].join(':')]

    c2 ? r[c2] : r
  end

  def self.copy(execution, code)

    Flor.dup(inflate(execution, code))
  end

  def self.inflate_all(execution, h)

    h.each do |k, v|
      if v.is_a?(String) && v[0, 7] == 'SHA256:'
        h[k] = execution['ashes'][v]
      elsif v.is_a?(Flor::Ash)
        h[k] = v.inflate
      end
    end if h

    h
  end
end

