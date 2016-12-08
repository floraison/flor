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

  def self.to_a(o)

    o.nil? ? nil : Array(o)
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

  def self.split_fei(fei)

    if m = fei.match(/\A([^-]+-[^-]+-\d+\.\d+\.[^-]+)-(.*)\z/)
      [ m[1], m[2] ]
    else
      [ nil ]
    end
  end

  def self.exid(fei)

    split_fei(fei).first
  end

  def self.split_nid(nid)

    nid.split('-')
  end

  def self.child_id(nid)

    nid ? nid.split('_').last.split('-').first.to_i : nil
  end

  def self.next_child_id(nid)

    child_id(nid) + 1
  end

  def self.sub_nid(nid, subid)

    "#{nid.split('-').first}-#{subid}"
  end

  # Remove the sub_nid if any.
  #
  def self.master_nid(nid)

    nid.split('-').first
  end

  def self.child_nid(nid, i, sub=0)

    ni, d = nid.split('-')
    d = sub if d == nil && sub > 0

    "#{ni}_#{i}#{d ? "-#{d}" : ''}"
  end

  def self.parent_id(nid)

    if i = nid.rindex('_')
      nid[0, i]
    else
      nil
    end
  end

  def self.parent_nid(nid, remove_subnid=false)

    _, sub = nid.split('-')
    i = nid.rindex('_')

    return nil unless i
    "#{nid[0, i]}#{remove_subnid || sub.nil? ? nil : "-#{sub}"}"
  end

  def self.is_nid?(s)

    !! (s.is_a?(String) && s.match(/\A[0-9]+(?:_[0-9]+)*(?:-[0-9]+)?\z/))
  end

  #
  # misc
  #
  # miscellaneous functions

  def self.dup(o)

    Marshal.load(Marshal.dump(o))
  end

  def self.deep_freeze(o)

    if o.is_a?(Array)
      o.each { |e| e.freeze }
    elsif o.is_a?(Hash)
      o.each { |k, v| k.freeze; v.freeze }
    end

    o.freeze
  end

  def self.false?(o)

    o == nil || o == false
  end

  def self.true?(o)

    o != nil && o != false
  end

  def self.to_error(o)

    h = {}
    h['kla'] = o.class.to_s
    t = nil

    if o.is_a?(Exception)

      h['msg'] = o.message

      t = o.backtrace

      if n = o.respond_to?(:node) && o.node
        h['lin'] = n.tree[2]
        #h['tre'] = n.tree
      end

    else

      h['msg'] = o.to_s

      t = caller[1..-1]
    end

    h['trc'] = t[0..(t.rindex { |l| l.match(/\/lib\/flor\//) }) + 1]

    h
  end

  def self.is_func?(o)

    o.is_a?(Array) &&
    o[0] == '_func' &&
    o[1].is_a?(Hash) && o[1].keys.sort == %w[ cnid fun nid ] &&
    o[2].is_a?(Integer) &&
    o.size < 5
  end

  def self.to_coll(o)

    #o.respond_to?(:to_a) ? o.to_a : [ a ]
    Array(o)
  end

  def self.truncate(s, l)

    s.length < l ? s : s[0, l] + '...'
  end

  #
  # functions about time

  # hour stamp
  def self.hstamp(t=Time.now.utc)

    t.strftime('%H:%M:%S.') + sprintf('%06d', t.usec) + (t.utc? ? 'u' : '')
  end

  # time stamp
  def self.tstamp(t=Time.now.utc)

    t.strftime('%Y%m%d.%H%M%S') + sprintf('%06d', t.usec) + (t.utc? ? 'u' : '')
  end

  # nice stamp
  def self.nstamp(t=Time.now.utc)

    t.strftime('%Y-%m-%d %H:%M:%S.') +
    sprintf('%06d', t.usec) +
    (t.utc? ? 'u' : '')
  end

  def self.to_time(ts)

    m = ts.match(/\A(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})(\d+)([uU]?)\z/)
    fail ArgumentError.new("cannot parse timestamp #{ts.inspect}") unless m

    return Time.utc(*m[1, 7].collect(&:to_i)) if m[8].length > 0
    Time.local(*m[1, 7].collect(&:to_i))
  end

  #
  # functions about domains and units

  NAME_REX = '[a-zA-Z0-9_]+'
  UNIT_NAME_REX = /\A#{NAME_REX}\z/
  DOMAIN_NAME_REX = /\A#{NAME_REX}(\.#{NAME_REX})*\z/
  FLOW_NAME_REX = /\A(#{NAME_REX}(?:\.#{NAME_REX})*)\.([a-zA-Z0-9_-]+)\z/

  def self.potential_unit_name?(s)

    s.is_a?(String) && s.match(UNIT_NAME_REX)
  end

  def self.potential_domain_name?(s)

    s.is_a?(String) && s.match(DOMAIN_NAME_REX)
  end

  def self.split_flow_name(s)

    if s.is_a?(String) && m = s.match(FLOW_NAME_REX)
      [ m[1], m[2] ]
    else
      nil
    end
  end

  def self.is_sub_domain?(dom, sub)

    fail ArgumentError.new(
      "not a domain #{dom.inspect}"
    ) unless potential_domain_name?(dom)

    fail ArgumentError.new(
      "not a sub domain #{sub.inspect}"
    ) unless potential_domain_name?(sub)

    sub == dom || sub[0, dom.length + 1] == dom + '.'
  end

  DOMAIN_UNIT_REX = /\A(#{NAME_REX}(?:\.#{NAME_REX})*)-(#{NAME_REX})[-\z]/

  def self.split_domain_unit(s)

    if m = DOMAIN_UNIT_REX.match(s)
      [ m[1], m[2] ]
    else
      []
    end
  end

  def self.domain(s)

    split_domain_unit(s).first
  end

  def self.unit(s)

    split_domain_unit(s).last
  end

  def self.to_pretty_s(o)

    #StringIO.open { |io| PP.pp(o, io, 79) }.string # :-(
    StringIO.new.tap { |io| PP.pp(o, io, 79) }.string
  end
end

