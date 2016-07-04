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


module Flor::Ash
  extend self # so that methods can be used as module methods

  ASH_KEYS = %w[ payload ]

  def compute_ash(value)

    return value if value.is_a?(String)

    j = (value == nil) ? 'null' : JSON.dump(value)
      # so that Ruby 1.9.x doesn't choke

    "SHA256:#{Digest::SHA256.hexdigest(j)}"
  end

  def ash?(s)

    s.is_a?(String) && s.match(/\ASHA256:[0-9A-Fa-f]+(:.+)?\z/)
  end

  def lookup_ash(ash, copy=false)

    return (copy ? Flor.dup(ash) : ash) unless ash?(ash)

    c0, c1 = ash.index(':'), ash.rindex(':')

    r =
      if c1 > c0
        (@execution['ashes'][ash[0..c1 - 1]] || {})[ash[c1 + 1..-1]]
      else
        @execution['ashes'][ash]
      end

    copy ? Flor.dup(r) : r
  end

  def ash_all!(h)

    ASH_KEYS.each { |k| ash!(h, k) }

    h
  end

  def unash_all!(h, copy=false)

    ASH_KEYS.each { |k| unash!(h, k, copy) }

    h
  end

  def ash(h, key)

    val = h[key]

    return val if ash?(val)

    ash = compute_ash(val)

    @execution['ashes'][ash] = Flor.deep_freeze(val) \
      unless @execution['ashes'].has_key?(ash)

    ash
  end

  def ash!(h, key)

    if h.has_key?(key)
      h[key] = ash(h, key)
    else
      nil
    end
  end

  def ash_ref!(h, key, subkey)

    "#{ash!(h, key)}:#{subkey}"
  end

  def unash(h, key)

    lookup_ash(h[key])
  end

  def unash!(h, key, copy=false)

    code = h[key]

    if code.is_a?(String)
      h[key] = lookup_ash(code, copy)
    elsif copy && code.frozen?
      h[key] = Flor.dup(code)
    else
      code
    end
  end
end

