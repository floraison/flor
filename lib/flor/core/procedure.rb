
class Flor::Procedure < Flor::Node

  class << self

    def inherited(subclass)

      (@@inherited ||= []) << subclass
    end

    def [](name)

      @@inherited.find { |k| k.names && k.names.include?(name) }
    end

    def names(*names)

      names = names.flatten
      @names = names if names.any?
      @core = !! caller.find { |l| l.match(/flor\/pcore/) } if names.any?

      @names
    end

    alias :name :names

    def core?; @core; end

    def make(executor, node, message)

      heap = node['heat'] ? node['heap'] : nil

      fail ArgumentError.new(
        "cannot determine procedure " +
        "#{{ heat: node['heat'], heap: node['heap'] }.inspect}"
      ) unless heap

      heac = self[heap]

      fail NameError.new(
        "unknown procedure #{heap.inspect}"
      ) unless heac

      heac.new(executor, node, message)
    end
  end

  def pre_execute

    # empty default implementation
  end

  def trigger_on_error

    @message['on_error'] = true

    close_node('on-error')

    @node['on_receive_last'] =
      apply(@node['on_error'].shift, [ @message ], tree[2])

    do_wrap_cancel_children ||
    do_receive # which should trigger 'on_receive_last'
  end

  def debug_tree(nid=nil)

    nid ||= self.nid
    tree = lookup_tree(nid)

    Flor.print_tree(tree, nid)
  end

  def debug_msg(msg=message)

    puts Flor.detail_msg(@executor, msg)
  end

  def end

    end_node
  end

  def flank

    @node['tree'] = Flor.dup(tree)
    @node['noreply'] = true

    wrap('nid' => parent, 'flavour' => 'flank')
  end

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

  def has_att?(k)

    @node['atts'].collect(&:first).include?(k)
  end

  def att_a(*keys)

    if keys.last == nil
      keys.pop
      Flor.to_a(att(*keys))
    else
      Array(att(*keys))
    end
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

  def unatt_unkeyed_children(first_only=false)

    found = false

    unkeyed, keyed =
      att_children.partition { |c|
        if found
          false
        else
          is_unkeyed = c[1].size == 1
          found = true if is_unkeyed && first_only
          is_unkeyed
        end
      }

    unkeyed = unkeyed
      .collect { |c| c[1].first }
      .reject { |c| c[0] == '_' && c[1] == [] }

    cn = keyed + unkeyed + non_att_children

    @node['tree'] = [ tree[0], cn, tree[2] ] if cn != children
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

    @node['tree'] = [ tree[0], cn, tree[2] ]
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

  # The executor calls #do_receive, while most procedure implementations
  # override #receive...
  #
  def do_receive

    remove = @message['flavour'] != 'flank'

    from_child = nil
    from_child = cnodes.delete(from) if cnodes_any? && remove

    if node_closed?
      return receive_from_child_when_closed if from_child
      return receive_when_closed
    elsif node_ended?
      return receive_when_ended
    end

    receive
  end

  def pop_on_receive_last

    orl = @node['on_receive_last']

    return nil unless orl
    return nil if orl.empty?

    open_node unless node_status['flavour'] == 'on-error'
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

    (cnodes.empty? && pop_on_receive_last) || wrap_reply
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

    @fcid && (c = children[@fcid]) && c[0] == '_att'
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

  def receive_non_att

    if @node['rets']
      @node['rets'] << Flor.dup(payload['ret'])
      @node['mtime'] = Flor.tstamp
    end

    return receive_last if children[@ncid] == nil
    execute_child(@ncid)
  end

  def receive_last

    wrap_reply
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
    m['nid'] = @node['noreply'] ? nil : parent
    m['from'] = nid

    m['sm'] = @message['m']

    ret =
      if @node.has_key?('aret') # from the 'ret' common attribute
        @node['aret']
      elsif h.has_key?('ret')
        h.delete('ret')
      else
        :no
      end

    m['payload'] = payload.current

    m.merge!(h)

    m['payload']['ret'] = ret if ret != :no

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
      return node if mode == '' && Flor.deep_has_key?(vars, k)
    end

    if cnode = mode == '' && @execution['nodes'][node['cnid']]
      return cnode if Flor.deep_has_key?(cnode['vars'], k)
    end

    par = parent_node(node)

    return node if vars && par == nil && mode == 'g'
    return lookup_var_node(par, mode, k) if par

    nil
  end

  def set_var(mode, k, v)

    fail IndexError.new("cannot set domain variables") if mode == 'd'

    node = lookup_var_node(@node, mode, k)
    node = lookup_var_node(@node, 'l', k) if node.nil? && mode == ''

    if node

      v = Flor.deep_set(node['vars'], k, v)

      return v unless v.is_a?(Symbol)
    end

    fail IndexError.new("couldn't set var #{mode}v.#{k}")
  end

  def set_field(k, v)

    value = Flor.deep_set(payload.copy, k, v)

    fail IndexError.new("couldn't set field #{k}") if value.is_a?(Symbol)

    value
  end

  def set_value(k, v)

    return if k == '_'

    cat, mod, key = key_split(k)

    case cat[0, 1]
    when 'f' then set_field(key, v)
    when 'v' then set_var(mod, key, v)
    #when 'w' then set_war(key, v)
    else fail IndexError.new("don't know how to set #{k.inspect}")
    end
  end

  def apply(fun, args, line, anid=true)

    fni = fun[1]['nid'] # fun nid
    ani = anid ? Flor.sub_nid(fni, counter_next('subs')) : fni
      # the "trap" apply doesn't want a subid generated before it triggers...

    cni = fun[1]['cnid'] # closure nid

    t = fun[1]['tree']
    t = t || lookup_tree(fni) # TODO when fun[1]['tree'] is settled, drop me
    fail ArgumentError.new("couldn't find function at #{fni}") unless t

    t = t[0] if t[0].is_a?(Array)
    t = t[1][0] if t[0] == '_att'

    sig = t[1].select { |c| c[0] == '_att' }
    sig = sig.drop(1) if t[0] == 'define'

    vars = {}
    vars['arguments'] = args # should I dup?
    sig.each_with_index do |att, i|
      key = att[1].first[0]
      vars[key] = args[i]
    end

    ms = wrap(
      'point' => 'execute',
      'nid' => ani,
      'tree' => [ '_apply', t[1], line ],
      'vars' => vars,
      'cnid' => cni)

    if oe = fun[1]['on_error']
      ms.first['on_error'] = oe
    end

    ms
  end

  def wrap_cancel_nodes(nids, h)

    (nids || [])
      .collect { |i| wrap_cancel(h.merge('nid' => i, 'from' => nid)) }
      .flatten(1)
  end

  def wrap_cancelled

    wrap(
      'cause' => 'cancel',
      'payload' => @message['payload'] || @node['payload'])
  end

  def wrap_cancel_children(h={})

    wrap_cancel_nodes(cnodes, h)
  end

  def do_wrap_cancel_children(h={})

    wrap_cancel_children(h).instance_eval { |ms| ms.any? ? ms : nil }
  end

  # The executor calls #do_cancel, while most procedure implementations
  # override #cancel...
  #
  def do_cancel

    if @message['flavour'] == 'kill'

      return [] if node_ended?
      kill

    else

      orl = @message['on_receive_last']
      @node['on_receive_last'] = orl if orl

      return cancel_when_ended if node_ended?
      return cancel_when_closed if node_closed?
      cancel
    end
  end

  def cancel_when_ended

    [] # node has already emitted reply to parent, ignore any later request
  end

  def cancel_when_closed

    [] # by default, no effect
  end

  def cancel

    close_node

    do_wrap_cancel_children ||
    pop_on_receive_last ||
    wrap_cancelled
  end

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
#Flor.print_tree(t, nid)

    m = @message.dup
    m['tree'] = t
    m['rewritten'] = tree

    m
  end
end

# A namespace for primitive procedures
#
module Flor::Pro; end

