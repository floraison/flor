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


module Flor

  def self.to_s(o=nil, k=nil)

    return 'FlorModule' if o == nil && k == nil
      # should it emerge somewhere...

    return o.collect { |e| Flor.to_s(e, k) }.join("\n") if o.is_a?(Array)

    if o.is_a?(Hash)

      return send("message_#{k}_to_s", o) if k && o['point'].is_a?(String)
      return message_to_s(o) if o['point'].is_a?(String)

      return send("node_#{k}_to_s", o) if k && o.has_key?('parent')
      return node_to_s(o) if o['parent'].is_a?(String)
    end

    return [ o, k ].inspect if k
    o.inspect
  end

  def self.message_to_s(m)

    s = StringIO.new
    s << '(msg ' << m['nid'] << ' ' << m['point']
    %w[ from flavour ].each { |k|
      s << ' ' << k << ':' << m[k].to_s if m.has_key?(k) }
    s << ')'

    s.string
  end

  def self.node_status_to_s(n)

    s = StringIO.new
    stas = n['status'].reverse
    while sta = stas.shift
      s << '(status ' << (sta['status'] || 'o') # o for open
      s << ' pt:' << sta['point']
      s << ' fla:' << sta['flavour'] if sta['flavour']
      s << ' fro:' << sta['from'] if sta['from']
      s << ')'
      s << "\n" if stas.any?
    end

    s.string
  end

  def self.node_to_s(n) # there is already a .node_to_s in log.rb

    n.inspect
  end
end

