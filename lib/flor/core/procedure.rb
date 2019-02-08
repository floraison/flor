
class Flor::Procedure < Flor::Node

  # "Returning vars" variables to pass back to pass upon reply.
  # In the 'receive' messages, it's a hash under the key 'rvars'.
  #
  RVARS = %w[ idx ]

  # Attributes that when given alone are turned to "true" attributes.
  #
  # For example `sequence flank` gets turned to `sequence flank: true`
  #
  # The transformation occurs in Flor::Pro::Att ("_att").
  #
  TRUE_ATTS = %w[ flank off disabled ]

  class << self

    def inherited(subclass)

      (@@inherited ||= []) << subclass
    end

    def [](name)

      @@inherited.find { |k| k.names && k.names.include?(name) }
    end

    def names(*names)

      @names = [] unless defined?(@names)

      if (names = names.flatten).any?
        @names = names
        @core = !! caller.find { |l| l.match(/flor\/pcore/) }
      end

      @names
    end

    alias :name :names

    def core?; @core; end

    def make(executor, node, message)

      heap = node['heap']
      heac = self[heap]

      fail NameError.new("unknown procedure #{heap.inspect}") \
        unless heac

      heac.new(executor, node, message)
    end
  end

  def pre_execute

    # empty default implementation
  end

  def prepare_on_receive_last(on_x, max=-1)

    on_x
      .inject([]) { |a, (criteria, mop)|

        next a if max > 0 && a.size >= max
        next a unless match_on?(criteria)

        msg = Flor.dup(@message)

        a.concat(
          if Flor.is_message?(mop)
            [ Flor.dup(mop).merge!('msg' => msg) ]
          else # procedure
            args = [ [ 'msg', msg ], [ 'err', msg['error'] ] ]
            apply(mop, args, mop[2])
          end) }
  end

  def trigger_on_error

    @message['on_error'] = true

    close_node('on-error')

    @node['on_receive_last'] =
      prepare_on_receive_last(@node['on_error'], 1)

    do_wrap_cancel_children ||
    do_receive # which should trigger 'on_receive_last'
  end

  def debug_tree(nid=nil)

    nid ||= self.nid
    tree = lookup_tree(nid)

    puts Flor.tree_to_s(tree, nid)
  end

  def debug_msg(msg=message)

    puts Flor.detail_msg(@executor, msg)
  end

  def end

    end_node
  end

  def flank

    @node['tree'] = Flor.dup(tree)
    @node['replyto'] = nil

    wrap('nid' => parent, 'flavour' => 'flank')
  end

  def heap; @node['heap']; end

  protected

  def counter_next(k)

    @executor.counter_next(k)
  end

  def stack_status(flavour, status)

    h = {
      'point' => @message['point'], 'status' => status, 'ctime' => Flor.tstamp }
    h['flavour'] = flavour if flavour
    mm = @message['m']; h['m'] = mm if mm
    mf = @message['from']; h['from'] = mf if mf

    s = node_status
    @node['status'].pop if s['m'] == h['m'] && s['status'] != 'ended'
      # only keep the latest effect of a message (probably "ended")

    @node['status'] << h
  end

  def close_node(flavour=@message['flavour'])
    stack_status(flavour, 'closed')
  end
  def open_node
    stack_status(@message['flavour'], nil)
  end
  def end_node
    stack_status(@message['flavour'], 'ended')
  end

  def children

    tree[1]
  end

  def att_children

    children.select { |c| c[0] == '_att' }
  end

  def non_att_children

    children.select { |c| c[0] != '_att' }
  end

  def non_att_count

    non_att_children.size
  end

  def unkeyed_children

    children.select { |c| c[0] != '_att' || c[1].size == 1 }
  end

  def first_unkeyed_child_id

    children.index { |c| c[0] != '_att' || c[1].size == 1 }
  end

  def first_non_att_child_id

    children.index { |c| c[0] != '_att' }
  end

  def att(*keys)

    return nil unless @node['atts']

    keys.each do |k|
      k = k.to_s unless k == nil
      a = @node['atts'].assoc(k)
      return a.last if a
    end

    nil
  end

  def atts(*keys)

    return nil unless @node['atts']

    @node['atts']
      .select { |k, _| keys.include?(k == nil ? nil : k.to_s) }
      .collect { |_, v| v }
  end

  def has_att?(k)

    @node['atts'].collect(&:first).include?(k)
  end

  def att_a(*keys)

    a =
      if keys.last == nil
        keys.pop
        Flor.to_a(att(*keys))
      else
        Array(att(*keys))
      end

    return [ a ] if Flor.is_regex_tree?(a)
    a
  end

  def tags_to_nids(tags)

    tags = Array(tags)

    @execution['nodes'].inject([]) { |a, (nid, n)|
      a << nid if ((n['tags'] || []) & tags).any?
      a
    }
  end

  def execute_child(index=0, sub=nil, h=nil)

    return wrap_reply \
      if index < 0 || ( ! tree[1].is_a?(Array)) || tree[1][index] == nil

    sub = counter_next('subs') if sub == true

    cnid = Flor.child_nid(nid, index, sub)

    hh = {
      'point' => 'execute',
      'nid' => cnid,
      'tree' => tree[1][index],
      'payload' => payload.current }
    hh.merge!(h) if h

    wrap(hh)
  end

  def stays_an_att?(t)

    t[1].length == 1 &&
    t[1][0].is_a?(Array) &&
    t[1][0][1] == [] &&
    TRUE_ATTS.include?(t[1][0][0])
  end

  def unatt_unkeyed_children(first_only=false)

    found = false

    unkeyed, keyed =
      att_children.partition { |c|
        if found
          false
        elsif stays_an_att?(c)
          false
        else
          is_unkeyed = c[1].size == 1
          found = true if is_unkeyed && first_only
          is_unkeyed
        end }

    unkeyed = unkeyed
      .collect { |c| c[1].first }
      #.reject { |c| c[0] == '_' && c[1] == [] }

    cn = keyed + unkeyed + non_att_children

    @node['tree'] = [ tree[0], cn, tree[2] ] if cn != children
  end

  def rep_first_child

    hd, cn, ln = tree

    ri = cn.index { |ct| ct[0] == '_ref' || Flor.is_single_ref_tree?(ct) }

    return unless ri

    cn1 = cn.dup
    rt = cn[ri]

    cn1[ri] =
      if rt[0] == '_ref'
        [ '_rep', rt[1], rt[2] ]
      else
        s, _, l = rt
        [ '_rep', [ [ '_sqs', s, l ] ], l ]
      end

    @node['tree'] = [ hd, cn1, ln ]
  end

  def unatt_first_unkeyed_child

    unatt_unkeyed_children(true)
  end

  def stringify_child(non_att_index)

    c = non_att_children[non_att_index]
    return unless c
    return unless c[1] == [] && c[0].is_a?(String)

    ci = children.index(c)
    cn = Flor.dup(children)
    cn[ci] = [ '_sqs', c[0], c[2] ]

    t = tree

    @node['tree'] = [ t[0], cn, t[2] ]
  end

  def stringify_first_child

    stringify_child(0)
  end

  def do_execute

    pre_execute

    pnode = @execution['nodes'][parent]
    cnodes = pnode && (pnode['cnodes'] ||= [])
    cnodes << nid if cnodes && ( ! cnodes.include?(nid))

    execute
  end

  def execute

    receive
  end

  # The executor calls #do_receive, while procedure implementations
  # override #receive...
  #
  def do_receive

    remove = @message['flavour'] != 'flank'

    from_child = nil
    from_child = cnodes.delete(from) if cnodes_any? && remove

    if di = @message['disable']
      #
      # the off: and the disable:/disabled: can achieve that

      wrap_reply('disabled' => di)

    elsif node_closed?

      if from_child || node_status_flavour
        receive_from_child_when_closed
      else
        receive_when_closed
      end

    elsif node_ended?

      receive_when_ended

    else

      receive
    end
  end

  def message_cause

    (@message['cause'] || [])
      .find { |c| c['nid'] == nid }
  end

  def pop_on_receive_last

    orl = @node['on_receive_last']

    return nil unless orl
    return nil if orl.empty?

    c = message_cause

    open_node \
      unless
        (node_status_flavour == 'on-error') || # TODO use the cause ???
        (c && c['cause'] == 'cancel' && @node['on_cancel']) ||
        (c && c['cause'] == 'timeout' && @node['on_timeout'])

    @node['on_receive_last'] = []

    @node['mtime'] = Flor.tstamp

    orl.each do |m|

      m['from'] = @node['parent'] if m['from'] == 'parent'

      #m['payload'] ||= Flor.dup(@node['payload'])
        # No, let re_applier supply payload
    end

    orl
  end

  def receive_from_child_when_closed

    (cnodes_empty? && pop_on_receive_last) || wrap_reply
  end

  def receive_when_closed

    []
  end

  def receive_when_ended

    []
  end

  def determine_fcid_and_ncid

    @fcid = point == 'receive' ? Flor.child_id(from) : nil
    @ncid = (@fcid || -1) + 1
  end

  def from_att?

    @fcid &&
    Flor.same_branch?(nid, from) &&
    (c = children[@fcid]) &&
    c[0] == '_att'
  end

  def from_sub_nid

    i = from.split('-')[1]
    i ? i.to_i : false
  end

  def from_error_handler?

    message['from_on_error'] == nid
  end

  def last_receive?

    children[@ncid] == nil
  end

  def receive

    determine_fcid_and_ncid

    return receive_first if @fcid == nil
    return receive_att if from_att?
    receive_non_att
  end

  def receive_first

    return receive_last_att if (c = children[0]) && c[0] != '_att'
    execute_child(@ncid)
  end

  def receive_att

    nt = children[@ncid]

    return receive_last_att if nt == nil || nt[0] != '_att'
    execute_child(@ncid)
  end

  def receive_last_att

    return receive_last if children[@ncid] == nil
    execute_child(@ncid)
  end

  # Prepare incoming ret for storage in @node['ret'] or @node['rets']
  #
  def receive_payload_ret

    Flor.dup(payload['ret'])
  end

  def receive_non_att

    if @node.has_key?('ret')
      @node['ret'] = receive_payload_ret
      @node['mtime'] = Flor.tstamp
    end
    if @node['rets']
      @node['rets'] << receive_payload_ret
      @node['mtime'] = Flor.tstamp
    end

    return receive_last if children[@ncid] == nil
    execute_child(@ncid)
  end

  def receive_last

    wrap_reply
  end

  # Grab on_error proc from incoming payload and stores it into parent node.
  #
  # Has no effect if there is no parent node.
  #
  def store_on(key, prc=payload['ret'], criteria=[ '*' ])

    return unless Flor.is_func_tree?(prc)

    pnode =
      @node; loop do
        pnode = parent_node(pnode)
        return unless pnode
        break unless %w[ _if _unless ].include?(pnode['heap'])
      end

    flavour = "on_#{key}"

    prc[1][flavour] = true

    a = (pnode[flavour] ||= [])
    i = a.index { |e| e[0] == criteria } || -1
      #
    a.insert(i, [ criteria, prc ])
  end

  # Used by 'cursor' (and 'loop') when
  # ```
  # cursor 'main'
  #   # is equivalent to:
  # cursor tag: 'main'
  # ```
  #
  def receive_unkeyed_tag_att

    return [] if @node['tags']
      # "tag:" encountered, walk away

    ret = @message['payload']['ret']
    ret = Array(ret).flatten
    ret = nil unless ret.any? && ret.all? { |e| e.is_a?(String) }

    return [] unless ret

    (@node['tags'] ||= []).concat(ret)

    wrap('point' => 'entered', 'nid' => nid, 'tags' => ret)
  end

  def wrap(h={})

    m = {}
    m['point'] = 'receive'
    m['exid'] = exid
    m['from'] = nid

    m['nid'] = # what node should receive this reply?
      if @node['noreply'] # for backward compatibility 2018-10-29
        nil
      elsif @node.has_key?('replyto')
        @node['replyto'] # nil or something like '0_1' or '0_2-4'
      else
        parent
      end

    m['sm'] = @message['m']

    m['cause'] = @message['cause'] if @message.has_key?('cause')

    ret =
      if @node.has_key?('aret') # from the 'ret' common attribute
        @node['aret']
      elsif h.has_key?('ret')
        h.delete('ret')
      else
        :no
      end

    m['payload'] = payload.dup_current

    m.merge!(h)

    m['payload']['ret'] = ret if ret != :no

    if vs = @node['vars']
      (RVARS & vs.keys).each { |k| (m['rvars'] ||= {})[k] = vs[k] }
    end
      #
      # initially for "cmap"
      #
      # was considering passing the whole vars back (as 'varz'), but
      # it got in the way... and it might be heavy

    %w[ error cancel timeout ]
      .each { |k|
        co = @node["child_on_#{k}"]
        m["on_#{k}_handler"] = co if co }

    [ m ]
  end

  alias wrap_reply wrap

  def wrap_error(o)

    wrap('point' => 'failed', 'error' => Flor.to_error(o))
  end

  def wrap_cancel(h)

    h['point'] ||= 'cancel'
    h['nid'] ||= nid
    #h['flavour'] ||= 'xxx'

    wrap(h)
  end

  def wrap_schedule(h)

    h['point'] ||= 'schedule'
    h['payload'] ||= {}
    h['nid'] ||= nid

    wrap(h)
  end

  def lookup_var_node(node, mode, k=nil)

    vars = node['vars']

    if vars
      return node if mode == 'l'
      return node if mode == '' && Dense.has_key?(vars, k)
    end

    if cnode = mode == '' && @execution['nodes'][node['cnid']]
      return cnode if Dense.has_key?(cnode['vars'], k)
    end

    par = parent_node(node)

    return node if vars && par == nil && mode == 'g'
    return lookup_var_node(par, mode, k) if par

    nil
  end

  # List all the tags the current node is "included" in.
  #
  def list_tags

    r = []
    n = @node

    while n
      ts = n['tags']
      r.concat(ts) if ts
      n = @execution['nodes'][n['parent']]
    end

    r
  end

  def set_var(mode, path, v)

    fail IndexError.new(
      'cannot set domain variables') if mode == 'd'

    begin

      node = lookup_var_node(@node, mode, path)
      node = lookup_var_node(@node, 'l', path) if node.nil? && mode == ''

      return Dense.set(node['vars'], path, v) if node

    rescue IndexError
    end

    fail IndexError.new(
      "couldn't set var #{Flor.path_to_s([ "#{mode}v" ] + path)}")
  end

  def set_field(path, v)

    Dense.set(payload.copy, path, v)

  rescue IndexError

    fail IndexError.new(
      "couldn't set field #{Flor.path_to_s(path)}")
  end

  def set_value(path, value)

    path = Dense::Path.make(path).to_a if path.is_a?(String)
#p [ path, '<-', value ]

    if path.length < 2
      set_var('', path, value)
    else
      case path.first
      when /\Af(?:ld|ield)?\z/
        set_field(path[1..-1], value)
      when /\A([lgd]?)v(?:ar|ariable)?\z/
        set_var($1, path[1..-1], value)
      else
        set_var('', path, value)
      end
    end
  end

  def splat_value(paths, value)

    val = value.dup

    while pa = paths.shift

      pa = Dense::Path.make(pa).to_a if pa.is_a?(String)

      if m = pa.last.match(Flor::SPLAT_REGEX)
        k, u = m[1, 2]
        l = (u == '_') ? val.length - paths.length : u.to_i
        set_value(pa[0..-2] + [ k ], val.take(l)) if k.length > 0
        val = val.drop(l)
      else
        set_value(pa, val.shift)
      end
    end
  end

  def apply(fun, args, line, opts={})

    anid = opts.has_key?(:anid) ? opts[:anid] : true
      # true => generate sub_nid

    fni = fun[1]['nid'] # fun nid
    ani = anid ? Flor.sub_nid(fni, counter_next('subs')) : fni
      # the "trap" apply doesn't want a subid generated before it triggers...

    cni = fun[1]['cnid'] # closure nid

    t = fun[1]['tree']
    #t = t || lookup_tree(fni) # TODO when fun[1]['tree'] is settled, drop me
    fail ArgumentError.new("couldn't find function at #{fni}") unless t

    t = t[0] if t[0].is_a?(Array)
    t = t[1][0] if t[0] == '_att'

    t[1][0][0] = '_name' if t[0] == 'define'

    #vars = opts[:vars] || {}
    #vars['arguments'] = args # Should I dup? Dup upstream?

    ms = wrap(
      'point' => 'execute',
      'nid' => ani,
      'tree' => [ '_apply', t[1], line ],
      'arguments' => args,
      'cnid' => cni)

    if oe = fun[1]['on_error']
      ms.first['on_error'] = oe
    end

    #if fs = opts[:fields]
    #  ms.first['payload'].merge!(fs)
    #end
      #
      # an idea from "sort" apply, may be useful later on...

    ms
  end

  def wrap_cancel_nodes(nids, h)

    (nids || [])
      .collect { |i| wrap_cancel(h.merge('nid' => i, 'from' => nid)) }
      .flatten(1)
  end

  def wrap_cancelled

    wrap('payload' => @message['payload'] || @node['payload'])
  end

  def wrap_cancel_children(h={})

    wrap_cancel_nodes(cnodes, h)
  end

  def do_wrap_cancel_children(h={})

    wrap_cancel_children(h).instance_eval { |ms| ms.any? ? ms : nil }
  end

  # Called by the executor, in turns call cancel and cancel_when_ methods
  # which may be overriden.
  #
  def do_cancel

    if orl = @message['on_receive_last']
      #
      # the message on_receive_last is used by the re_apply feature

      @node['on_receive_last'] = orl

    elsif @message['flavour'] == 'timeout' && ot = @node['on_timeout']

      @node['on_receive_last'] = prepare_on_receive_last(ot)

    elsif oc = @node['on_cancel']

      @node['on_receive_last'] = prepare_on_receive_last(oc)
    end

    return cancel_when_ended if node_ended?
    return cancel_when_closed if node_closed?

    cancel
  end

  # Called by the executor, in turns call kill and kill_when_ methods
  # which may be overriden.
  #
  def do_kill

    return kill_when_ended if node_ended?
    #return kill_when_closed if node_closed? # nothing of the sort

    kill
  end

  # Handle an incoming cancel message when the node has ended.
  # Open for override.
  #
  def cancel_when_ended

    [] # node has already emitted reply to parent, ignore any later request
  end

  # Handle an incoming cancel message when the node has closed.
  # Open for override (overridden by "sequence", "cursor", and "until")
  #
  def cancel_when_closed

    [] # by default, no effect
  end

  # When the node has ended, incoming kill messages are silenced ([] return).
  #
  def kill_when_ended

    [] # no effect
  end

  # The core cancel work, is overriden by some procedure implementations.
  #
  def cancel

    close_node

    do_wrap_cancel_children ||
    pop_on_receive_last ||
    wrap_cancelled
  end

  # The core kill work, open for override, but actually no procedure
  # provides a custom implementation. Kill is kill for every of the procs.
  #
  def kill

    close_node

    wrap_cancel_children('flavour' => 'kill') +
    wrap_cancelled
  end
end


# Not really a procedure, more like a macro, rewrites its tree and returns
# a new message to queue (with a rewritten tree).
#
class Flor::Macro < Flor::Procedure

  # Called by the executor.
  #
  def rewrite

    t = rewrite_tree
#puts Flor.tree_to_s(t, nid)

    m = @message.dup
    m['tree'] = t
    m['rewritten'] = tree

    m
  end
end

# A namespace for primitive procedures
#
module Flor::Pro; end

