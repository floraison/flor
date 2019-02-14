
module Flor

  NAME_REX = '[a-zA-Z0-9_]+'
  UNIT_NAME_REX = /\A#{NAME_REX}\z/
  DOMAIN_NAME_REX = /\A#{NAME_REX}(\.#{NAME_REX})*\z/
  FLOW_NAME_REX = /\A(#{NAME_REX}(?:\.#{NAME_REX})*)\.([a-zA-Z0-9_-]+)\z/

  #DOMAIN_UNIT_REX = /\A(#{NAME_REX}(?:\.#{NAME_REX})*)-(#{NAME_REX})[-\z]/
  DOMAIN_UNIT_REX = /\A(#{NAME_REX}(?:\.#{NAME_REX})*)-(#{NAME_REX})[-$]/

  SPLAT_REGEX = /\A(.*)__(_|\d+)\z/.freeze

  POINTS = %w[
    execute receive
    return
    entered left
    task detask
    schedule trigger
    signal cancel
    terminated failed ceased
    idle
  ]

  class << self

    def to_a(o)

      o.nil? ? nil : Array(o)
    end

    #
    # misc
    #
    # miscellaneous functions

    def env_i(k)

      v = ENV[k]; (v && v.match(/\A\d+\z/)) ? v.to_i : nil
    end

    # Returns a new, complete (not shallow), copy of the target instance.
    #
    def dup(o)

      Marshal.load(Marshal.dump(o))
    end

    def dup_and_merge(h, hh)

      self.dup(h).merge!(hh)
    end
    def dupm(h, hh); self.dup_and_merge(h, hh); end

    def deep_freeze(o)

      if o.is_a?(Array)
        o.each { |e| e.freeze }
      elsif o.is_a?(Hash)
        o.each { |k, v| k.freeze; v.freeze }
      end

      o.freeze
    end

    def false?(o)

      o == nil || o == false
    end

    def true?(o)

      o != nil && o != false
    end

    def to_error(o)

      h = {}
      h['kla'] = o.class == String ? 'Flor::FlorError' : o.class.to_s

      m, t =
        if o.is_a?(::Exception)
          [ o.message, o.backtrace ]
        else
          [ o.to_s, caller[1..-1] ]
        end

      if n = o.respond_to?(:node) && o.node
        h['prc'] = n.tree[0]
        h['lin'] = n.tree[2]
      end

      h['msg'] = m
      h['trc'] = t[0..(t.rindex { |l| l.match(/\/lib\/flor\//) }) + 1] if t
      h['cwd'] = Dir.pwd
      h['rlp'] = $: if o.is_a?(::LoadError)

      h
    end

    def to_error_message(message, err)

      m = message
        .select { |k, v|
          %w[ sm exid nid from payload tree er tasker ].include?(k) }

      m['point'] = 'failed'
      m['fpoint'] = message['point']
      m['fm'] = message['m']
      m['error'] = to_error(err)

      m
    end

    def const_lookup(s)

      s.split('::')
        .select { |ss| ss.length > 0 }
        .inject(Kernel) { |k, sk| k.const_get(sk, k == Kernel) }
    end

    def is_collection?(o)

      o.is_a?(Array) || o.is_a?(Hash)
    end

    def to_coll(o)

      #o.respond_to?(:to_a) ? o.to_a : [ a ]
      Array(o)
    end

    def relativize_path(path, from=Dir.getwd)

      path = File.absolute_path(path)

      path = path[from.length + 1..-1] if path[0, from.length] == from

      path || '.'
    end

    def is_message?(o)

      o.is_a?(Hash) &&
      o['point'].is_a?(String) &&
      o.keys.all? { |k| k.is_a?(String) }
    end

    def is_array_of_messages?(o)

      o.is_a?(Array) &&
      o.all? { |e| is_message?(o) }
    end

    def h_fetch(h, *keys)

      k = keys.find { |kk| h.has_key?(kk) }
      k ? h[k] : nil
    end

    def h_fetch_a(h, *keys)

      default = keys.last.is_a?(String) ? [] : keys.pop

      k = keys.find { |kk| h.has_key?(kk) }
      v = k ? h[k] : nil

      v_to_a(v) || default
    end

    def v_to_a(o)

      return o if o.is_a?(Array)
      return o.split(',') if o.is_a?(String)
      return nil if o.nil?

      fail ArgumentError.new("cannot turn instance of #{o.class} into an array")
    end

    def is_regex_string?(s)

      !! (
        s.is_a?(String) &&
        s[0] == '/' &&
        s.match(/\/[imxouesn]*\z/)
      )
    end

    def to_regex(o)

      s =
        if o.is_a?(String)
          o
        elsif o.is_a?(Array)
          if (o[0] == '_rxs' || o[0] == 'regex') && o[2].is_a?(Integer)
            o[1].to_s
          else
            "/#{o[0..-2].join}/#{o[-1]}"
          end
        else
          o.to_s
        end

      m = s.match(/\A\/(.*)\/([imxouesn]*)\z/)

      return Regexp.new(s) unless m

      m1 = m[1]
      e = (m[2].match(/[uesn]/) || [])[0]

      m1 =
        case e
        when 'u' then m1.encode('UTF-8')
        when 'e' then m1.encode('EUC-JP')
        when 's' then m1.encode('Windows-31J')
        when 'n' then m1.encode('ASCII-8BIT')
        else m1
        end

      flags = 0
      flags = flags | Regexp::EXTENDED if m[2].index('x')
      flags = flags | Regexp::IGNORECASE if m[2].index('i')
      #flags = flags | Regexp::MULTILINE if m[2].index('m')
      flags = flags | Regexp::FIXEDENCODING if e

      Regexp.new(m1, flags)
    end

    #
    # functions about time

    def isostamp(show_date, show_time, show_usec, time)

      t = (time || Time.now).utc
      s = StringIO.new

      s << t.strftime('%Y-%m-%d') if show_date
      s << t.strftime('T%H:%M:%S') if show_time
      s << sprintf('.%06d', t.usec) if show_time && show_usec
      s << 'Z' if show_time

      s.string
    end

    def tstamp(t=Time.now)

      isostamp(true, true, true, t)
    end

    def ststamp(t=Time.now)

      isostamp(true, true, false, t)
    end

    def dstamp(t=Time.now)

      isostamp(true, false, false, t)
    end

    def tamp(t=Time.now)

      t = t.utc
      s = StringIO.new
      s << t.strftime('%Y%m%dT%H%M%S') << sprintf('.%06dZ', t.usec)

      s.string
    end

    # hour stamp
    #
    def hstamp(t=Time.now)

      isostamp(false, true, true, t)
    end

#  def to_time(ts)
#
#    m = ts.match(/\A(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})(\d+)([uU]?)\z/)
#    fail ArgumentError.new("cannot parse timestamp #{ts.inspect}") unless m
#
#    return Time.utc(*m[1, 7].collect(&:to_i)) if m[8].length > 0
#    Time.local(*m[1, 7].collect(&:to_i))
#  end

    #
    # functions about domains and units

    def potential_unit_name?(s)

      s.is_a?(String) && !! s.match(UNIT_NAME_REX)
    end

    def potential_domain_name?(s)

      s.is_a?(String) && !! s.match(DOMAIN_NAME_REX)
    end

    def split_flow_name(s)

      if s.is_a?(String) && m = s.match(FLOW_NAME_REX)
        [ m[1], m[2] ]
      else
        nil
      end
    end

    def is_sub_domain?(dom, sub)

      fail ArgumentError.new(
        "not a domain #{dom.inspect}"
      ) unless potential_domain_name?(dom)

      fail ArgumentError.new(
        "not a sub domain #{sub.inspect}"
      ) unless potential_domain_name?(sub)

      sub == dom || sub[0, dom.length + 1] == dom + '.'
    end

    def split_domain_unit(s)

      if m = DOMAIN_UNIT_REX.match(s)
        [ m[1], m[2] ]
      else
        []
      end
    end

    def domain(s)

      split_domain_unit(s).first
    end

    def unit(s)

      split_domain_unit(s).last
    end

    def to_pretty_s(o, twidth=79)

      sio = StringIO.new
      PP.pp(o, sio, twidth)

      sio.string
    end


    #
    # tree

    def is_tree?(t)

      t.is_a?(Array) &&
      t.size > 2 &&
      (t[0].is_a?(String) || Flor.is_tree?(t[0])) &&
      t[2].is_a?(Integer)
    end

    def is_string_tree?(t, s=nil)

      t.is_a?(Array) &&
      t[2].is_a?(Integer) &&
      %w[ _sqs _dqs ].include?(t[0]) &&
      (s ? (t[1] == s) : t[1].is_a?(String))
    end

    def is_att_tree?(t)

      t.is_a?(Array) &&
      t[2].is_a?(Integer) &&
      t[0] == '_att' &&
      t[1].is_a?(Array)
    end

    def is_definition_tree?(t)

      t.is_a?(Array) &&
      Flor::Pro::Define.names.include?(t[0]) &&
      t[2].is_a?(Integer) &&
      t[1].is_a?(Array)
    end

    def is_def_tree?(t)

      is_definition_tree?(t) &&
      t[0] != 'define'
    end

    def is_array_of_trees?(o)

      o.is_a?(Array) &&
      o.all? { |e| Flor.is_tree?(e) }
    end

    def is_single_ref_tree?(t)

      t.is_a?(Array) && t[0].is_a?(String) && t[0] != '_' && t[1] == []
    end

#  # Array, object or atom tree
#  #
#  def is_value_tree?(o)
#
#    o.is_a?(Array) &&
#    %w[ _num _boo _sqs _dqs _rxs _nul _arr _obj ].include?(o[0]) &&
#    o[2].is_a?(Integer)
#  end

    def is_proc_tree?(o)

      o.is_a?(Array) &&
      o[0] == '_proc' &&
      o[2].is_a?(Integer) &&
      o[1].is_a?(Hash) &&
      o[1]['proc'].is_a?(String)
    end

    def is_func_tree?(o)

      o.is_a?(Array) &&
      o[0] == '_func' &&
      o[2].is_a?(Integer) &&
      o[1].is_a?(Hash) && (o[1].keys & %w[ nid cnid fun ]).size == 3
    end

    def is_tasker_tree?(o)

      # [ '_tasker', { 'tasker' => 'alan' }, -1 ]

      o.is_a?(Array) &&
      o[0] == '_tasker' &&
      o[2].is_a?(Integer) &&
      o[1].is_a?(Hash) &&
      o[1]['tasker'].is_a?(String)
    end

    def is_regex_tree?(o)

      o.is_a?(Array) &&
      o[0] == '_rxs' &&
      o[2].is_a?(Integer) &&
      o[1].is_a?(String) &&
      o[1].match(/\A\/.*\/[a-zA-Z]*\z/)
    end

    # Returns [ st, i ], the parent subtree for the final i index of the nid
    # Used when inserting updated subtrees.
    #
    def parent_tree_locate(t, nid)

      return nil if t == nil

      _, i, d = nid.split('_', 3)

      return [ t, nil ] if i == nil
      return [ t, i.to_i ] if d == nil
      parent_tree_locate(t[1][i.to_i], [ i, d ].join('_'))
    end

    # Returns the subtree down at the given nid
    #
    def tree_locate(t, nid)

      st, i = parent_tree_locate(t, nid)

      return nil if st == nil
      return st if i == nil
      st[1][i]
    end


    #
    # misc

    def point?(s)

      POINTS.include?(s)
    end

    def type(o)

      case o
      when Array then :array
      when Hash then :object
      when String then :string
      when true, false then :boolean
      when Numeric then :number
      when nil then :null
      else nil
      end
    end


    #
    # Dense paths

    def path_to_s(path)

      path_to_dense_path(path).to_s
    end

    def path_to_dense_path(path)

      Dense::Path.make(path.collect { |e| path_elt_to_dense_path_elt(e) })
    end

    def path_elt_to_dense_path_elt(elt)

      case elt
      #when String then elt
      #when Integer then elt
      when { 'dot' => true } then :dot
      when { 'star' => true } then :star
      when { 'dotstar' => true } then :star
      when Array then elt.collect { |e| path_elt_to_dense_path_elt(e) }
# TODO regexes
      else elt
      end
    end

    def tree_to_pp_s(t, out=StringIO.new, indent='')

      out.print("#{indent}[ '#{t[0]}', ")
      if t[1] == []
        out.print("[]")
      elsif t[1].is_a?(Array)
        out.print("[\n")
        t[1].each_with_index do |ct, i|
          tree_to_pp_s(ct, out, indent + '  ')
          if i < t[1].length - 1
            out.print(",\n")
          else
            out.print("\n#{indent}")
          end
        end
        out.print("]")
      else
        out.print(t[1].inspect)
      end
      out.print(", #{t[2]}")
      out.print(", '#{t[3]}'") if t[3]
      out.print(" ]")

      indent == '' ? out.string : nil
    end

    def to_string_keyed_hash(o)

      case o
      when Array
        o.collect { |e| to_string_keyed_hash(e) }
      when Hash
        o.inject({}) { |h, (k, v)| h[k.to_s] = to_string_keyed_hash(v); h }
      else
        o
      end
    end

    # Available as `Flor.migration_dir`
    #
    def migration_dir

      File.absolute_path(
        File.join(
          File.dirname(__FILE__), 'migrations'))
    end
  end
end

