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


module Flor

  #
  # deep
  #
  # functions for deep getting/setting in structures

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

  def self.deep_has_key?(o, k)

    val = o
    ks = k.split('.')

    loop do

      kk = ks.shift

      case val
        when Array
          i = to_index(kk)
          return false unless i
          return (i < 0 ? -i < val.length : i < val.length) if ks.empty?
          val = val[i]
        when Hash
          return val.has_key?(kk) if ks.empty?
          val = val[kk]
        else
          return false
      end
    end
  end


  #
  # djan
  #
  # functions about the "djan" silly version of JSON

  def self.to_djan(x, opts={})

    opts[:cl] = opts[:color] || opts[:colour]

    r =
      case x
        when nil then 'null'
        when String then string_to_d(x, opts)
        when Hash then object_to_d(x, opts)
        when Array then array_to_d(x, opts)
        when TrueClass then c_tru(x.to_s, opts)
        when FalseClass then c_tru(x.to_s, opts)
        else c_num(x.to_s, opts)
      end
    if opts[:inner]
      opts.delete(:inner)
      r = r[1..-2] if r[0, 1] == '[' || r[0, 1] == '{'
    end
    r
  end

  def self.s_to_d(x, opts={})

    x.is_a?(String) ? x : to_djan(x, opts)
  end

  class << self

    alias to_d to_djan

    protected # somehow

    # Black       0;30     Dark Gray     1;30
    # Blue        0;34     Light Blue    1;34
    # Green       0;32     Light Green   1;32
    # Cyan        0;36     Light Cyan    1;36
    # Red         0;31     Light Red     1;31
    # Purple      0;35     Light Purple  1;35
    # Brown       0;33     Yellow        1;33
    # Light Gray  0;37     White         1;37

    def c_inf(s, opts); opts[:cl] ? "[1;30m#{s}[0;0m" : s; end
    def c_str(s, opts); opts[:cl] ? "[1;33m#{s}[0;0m" : s; end
    def c_tru(s, opts); opts[:cl] ? "[0;32m#{s}[0;0m" : s; end
    def c_fal(s, opts); opts[:cl] ? "[0;31m#{s}[0;0m" : s; end
    def c_num(s, opts); opts[:cl] ? "[1;34m#{s}[0;0m" : s; end

    def c_key(s, opts)

      return s unless opts[:cl]

      s.match(/\A".*"\z/) ?
        "#{c_inf('"', opts)}[0;33m#{s[1..-2]}#{c_inf('"', opts)}" :
        "[0;33m#{s}[0;0m"
    end

    def string_to_d(x, opts)

      if (
        x.match(/\A[^: \b\f\n\r\t"',()\[\]{}#\\]+\z/) == nil ||
        x.to_i.to_s == x ||
        x.to_f.to_s == x
      )
        "#{c_inf('"', opts)}#{c_str(x.inspect[1..-2], opts)}#{c_inf('"', opts)}"
      else
        c_str(x, opts)
      end
    end

    def object_to_d(x, opts)

      a = [ '{ ', ': ', ', ', ' }' ]
      a = a.collect(&:strip) if x.empty? || opts[:compact]
      a = a.collect { |s| c_inf(s, opts) }
      a, b, c, d = a

      a +
      x.collect { |k, v|
        "#{c_key(to_djan(k, {}), opts)}#{b}#{to_djan(v, opts)}"
      }.join(c) +
      d
    end

    def array_to_d(x, opts)

      a = [ '[ ', ', ', ' ]' ]
      a = a.collect(&:strip) if x.empty? || opts[:compact]
      a = a.collect { |s| c_inf(s, opts) }
      a, b, c = a

      a + x.collect { |e| to_djan(e, opts) }.join(b) + c
    end
  end


  #
  # ids
  #
  # functions about exids, nids, sub_nids, ...

  def self.child_id(nid)

    nid
      .split('_').last
      .split('-').first
      .to_i
  end

  def self.next_child_id(nid)

    child_id(nid) + 1
  end

  # Remove the sub_nid if any.
  #
  def self.master_nid(nid)

    nid.split('-').first
  end

  def self.child_nid(nid, i)

    ab = nid.split('-')

    "#{ab[0]}_#{i}#{ab[1] ? '-' : ''}#{ab[1]}"
  end

  def self.parent_id(nid)

    if i = nid.rindex('_')
      nid[0, i]
    else
      nil
    end
  end


  #
  # pretty printing

  def self.print_tree(tree, nid='0', opts={ color: true })

#pp tree if nid == '0'
    _dg, _yl, _rs =
      opts[:color] && $stdout.tty? ?
      [ "[1;30m", "[1;33m", "[0;0m" ] :
      [ '', '', '' ]

    h = "#{_yl}#{Flor.s_to_d(tree[0], compact: true)}"
    c = tree[1].is_a?(Array) ? '' : " #{_yl}#{tree[1]}"
    l = " #{_dg}#{tree[2]}"

    puts "#{_dg}+" if nid == '0'
    puts "#{_dg}| #{nid} #{h}#{c}#{l}#{_rs}"
    if tree[1].is_a?(Array)
      tree[1].each_with_index { |ct, i| print_tree(ct, "#{nid}_#{i}", opts) }
    end
    puts "#{_dg}+#{_rs}" if nid == '0'
  end

  def self.print_src(tree, opts={ color: true })

    _dg, _rs =
      opts[:color] && $stdout.tty? ?
      [ "[1;30m", "[0;0m" ] :
      [ '', '' ]

    s =
      if tree.is_a?(String)
        tree
      else
        StringIO.new.tap { |o| PP.pp(tree, o, 77) }.string
      end
    ss = s.split("\n")
    ind =
      ss.inject(9999) { |i, l|
        m = l.match(/\A(\s+)/)
        ii = (m && m[1].length) || 9999
        ii < i ? ii : i
      }
    ss.each do |l|
      next if l.strip.length < 1
      puts "#{_dg}|#{l[ind + 1..-1]}#{_rs}"
    end
  end


  #
  # misc
  #
  # miscellaneous functions

  def self.dup(o)

    Marshal.load(Marshal.dump(o))
  end

  def self.tstamp(t=Time.now.utc)

    t.strftime('%Y%m%d.%H%M%S') + sprintf('%06d', t.usec)
  end

  def self.false?(o)

    o == nil || o == false
  end

  def self.true?(o)

    o != nil && o != false
  end

  def self.to_error(o)

    if o.respond_to?(:message)
      { 'msg' => o.message,
        'kla' => o.class.to_s,
        'trc' => o.backtrace[0, 4] }
    else
      { 'msg' => o.to_s }
    end
  end

  def self.is_tree?(o)

    o.is_a?(Array) &&
    (o[0].is_a?(String) || is_tree?(o[0])) &&
    o[1].is_a?(Hash) &&
    o[2].is_a?(Fixnum) &&
    o[3].is_a?(Array) &&
    o[3].all? { |e| is_tree?(e) } # overkill?
  end

  def self.is_val?(o)

    o.is_a?(Array) &&
    o[0] == 'val' &&
    o[1].is_a?(Hash) &&
    o[2].is_a?(Fixnum) &&
    o[3] == []
  end

  def self.is_string_val?(o)

    o.is_a?(Array) &&
    o[0] == 'val' &&
    o[1].is_a?(Hash) &&
    %w[ sqstring dqstring ].include?(o[1]['t']) &&
    o[1]['v'].is_a?(String) &&
    o[2].is_a?(Fixnum) &&
    o[3] == []
  end

  def self.de_val(o)

    return o unless is_val?(o)
    return o if o[1]['t'] == 'function'
    o[1]['v']
  end
end

