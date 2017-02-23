
module Flor

  def self.to_a(o)

    o.nil? ? nil : Array(o)
  end

  #
  # misc
  #
  # miscellaneous functions

  def self.dup(o)

    Marshal.load(Marshal.dump(o))
  end

  def self.dup_and_merge(h, hh)

    self.dup(h).merge(hh)
  end
  def self.dupm(h, hh); self.dup_and_merge(h, hh); end

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

    h['trc'] = t[0..(t.rindex { |l| l.match(/\/lib\/flor\//) }) + 1] if t

    h
  end

  def self.const_lookup(s)

    s.split('::').inject(Kernel) { |k, sk| k.const_get(sk) }
  end

  def self.to_coll(o)

    #o.respond_to?(:to_a) ? o.to_a : [ a ]
    Array(o)
  end

  def self.relativize_path(path, from=Dir.getwd)

    path = File.absolute_path(path)

    path = path[from.length + 1..-1] if path[0, from.length] == from

    path
  end

  def self.is_array_of_messages?(o)

    o.is_a?(Array) &&
    o.all? { |e|
      e.is_a?(Hash) &&
      e['point'].is_a?(String) &&
      e.keys.all? { |k| k.is_a?(String) } }
  end

  #
  # functions about time

  def self.isostamp(show_date, show_time, show_usec, time)

    t = (time || Time.now).utc
    s = StringIO.new

    s << t.strftime('%Y-%m-%d') if show_date
    s << t.strftime('T%H:%M:%S') if show_time
    s << sprintf('.%06d', t.usec) if show_time && show_usec
    s << 'Z' if show_time

    s.string
  end

  def self.tstamp(t=Time.now)

    isostamp(true, true, true, t)
  end

  def self.ststamp(t=Time.now)

    isostamp(true, true, false, t)
  end

  def self.dstamp(t=Time.now)

    isostamp(true, false, false, t)
  end

  # hour stamp
  #
  def self.hstamp(t=Time.now)

    isostamp(false, true, true, t)
  end

#  def self.to_time(ts)
#
#    m = ts.match(/\A(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})(\d+)([uU]?)\z/)
#    fail ArgumentError.new("cannot parse timestamp #{ts.inspect}") unless m
#
#    return Time.utc(*m[1, 7].collect(&:to_i)) if m[8].length > 0
#    Time.local(*m[1, 7].collect(&:to_i))
#  end

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

  def self.to_pretty_s(o, twidth=79)

    sio = StringIO.new
    PP.pp(o, sio, twidth)

    sio.string
  end


  #
  # tree

  def self.is_tree?(t)

    t.is_a?(Array) &&
    t.size > 2 &&
    (t[0].is_a?(String) || Flor.is_tree?(t[0])) &&
    t[2].is_a?(Integer)
  end

  def self.is_att_tree?(t)

    t.is_a?(Array) &&
    t[0] == '_att' &&
    t[1].is_a?(Array)
  end

  def self.is_array_of_trees?(o)

    o.is_a?(Array) && o.all? { |e| Flor.is_tree?(e) }
  end

  def self.is_proc_tree?(o)

    o.is_a?(Array) &&
    o[0] == '_proc' &&
    o[2].is_a?(Integer) &&
    o[1].is_a?(Hash) &&
    o[1]['proc'].is_a?(String)
  end

  def self.is_func_tree?(o)

    o.is_a?(Array) &&
    o[0] == '_func' &&
    o[2].is_a?(Integer) &&
    o[1].is_a?(Hash) && (o[1].keys & %w[ nid cnid fun ]).size == 3
  end

  def self.is_task_tree?(o)

    o.is_a?(Array) &&
    o[0] == '_task' &&
    o[2].is_a?(Integer) &&
    o[1].is_a?(Hash) &&
    o[1]['task'].is_a?(String)
  end

  def self.is_tree_head_tree?(o)

    o.is_a?(Array) &&
    Flor.is_tree?(o[0]) &&
    Flor.is_array_of_trees?(o[1]) &&
    o[2].is_a?(Integer)
  end

  # Returns [ st, i ], the parent subtree for the final i index of the nid
  # Used when inserting updated subtrees.
  #
  def self.parent_tree_locate(t, nid)

    return nil if t == nil

    n, i, d = nid.split('_', 3)

    return [ t, nil ] if i == nil
    return [ t, i.to_i ] if ! d
    parent_tree_locate(t[1][i.to_i], [ i, d ].join('_'))
  end

  # Returns the subtree down at the given nid
  #
  def self.tree_locate(t, nid)

    st, i = parent_tree_locate(t, nid)

    return nil if st == nil
    return st if i == nil
    st[1][i]
  end
end

