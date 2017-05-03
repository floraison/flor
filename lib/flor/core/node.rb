
class Flor::Node

  class Payload
    def initialize(node, type=:node)
      @node = node
      @type = type
    end
    def has_key?(k)
      current.has_key?(k)
    end
    def [](k)
      current[k]
    end
    def []=(k, v)
      copy[k] = v
    end
    def delete(k)
      copy.delete(k)
    end
    def copy
      container['pld'] ||= Flor.dup(original)
    end
    def current
      container['pld'] || container['payload']
    end
    def copy_current
      Flor.dup(current)
    end
    def merge(h)
      current.merge(h)
    end
    protected
    def container
      @type == :node ? @node.h : @node.message
    end
    def original
      container['payload']
    end
  end

  attr_reader :message

  def initialize(executor, node, message)

    @executor, @execution =
      case executor
        when nil then [ nil, nil ] # for some tests
        when Hash then [ nil, executor ] # from some other tests
        else [ executor, executor.execution ] # vanilla case
      end

    @node =
      if node
        node
      elsif message
        @execution['nodes'][message['nid']]
      else
        nil
      end

    @message = message
  end

  def h; @node; end

  def exid; @execution['exid']; end
  def nid; @node['nid']; end
  def parent; @node['parent']; end

  def domain; Flor.domain(@execution['exid']); end

  def point; @message['point']; end
  def from; @message['from']; end

  def cnodes; @node['cnodes']; end
  def cnodes_any?; cnodes && cnodes.any?; end

  def payload
    @message_payload ||= Payload.new(self, :message)
  end

  def node_status
    @node['status'].last
  end
  def node_closed?
    node_status['status'] == 'closed'
  end
  def node_ended?
    node_status['status'] == 'ended'
  end
  def node_open?
    node_status['status'] == nil
  end

  def node_payload
    @node_payload ||= Payload.new(self)
  end
  def node_payload_ret
    Flor.dup(node_payload['ret'])
  end

  def message_or_node_payload
    payload.current ? payload : node_payload
  end

  def lookup_tree(nid)

    return nil unless nid

    node = @execution['nodes'][nid]

    tree = node && node['tree']
    return tree if tree

    par = node && node['parent']
    cid = Flor.child_id(nid)

    tree = par && lookup_tree(par)
    return subtree(tree, par, nid) if tree

    return nil if node

    tree = lookup_tree(Flor.parent_nid(nid))
    return tree[1][cid] if tree

    #tree = lookup_tree(Flor.parent_nid(nid, true))
    #return tree[1][cid] if tree
      #
      # might become necessary at some point

    nil
  end

  #def lookup_tree(nid)
  #  climb_down_for_tree(nid) ||
  #  climb_up_for_tree(nid) ||
  #end
  #def climb_up_for_tree(nid)
  #  # ...
  #end
  #def climb_down_for_tree(nid)
  #  # ...
  #end
    #
    # that might be the way...

  def lookup(name, silence_index_error=false)

    cat, mod, key_and_path = key_split(name)
    key, pth = key_and_path.split('.', 2)

    if [ cat, mod, key ] == [ 'v', '', 'node' ]
      lookup_in_node(pth)
    elsif cat == 'v'
      lookup_var(@node, mod, key, pth)
    elsif cat == 't'
      lookup_tag(mod, key)
    else
      lookup_field(mod, key_and_path)
    end

  rescue IndexError

    raise unless silence_index_error
  end

  class Expander < Flor::Dollar

    def initialize(n); @node = n; end

    def lookup(k)

      return @node.nid if k == 'nid'
      return @node.exid if k == 'exid'
      return Flor.tstamp if k == 'tstamp'

      r = @node.lookup(k, true)
      r.is_a?(Symbol) ? nil : r
    end
  end

  def expand(s)

    return s unless s.is_a?(String)

    Expander.new(self).expand(s)
  end

  def deref(o)

    return o unless o.is_a?(String)

    v = lookup(o)

    return v unless Flor.is_tree?(v)
    return v unless v[1].is_a?(Hash)

    return v unless %w[ _proc _task _func ].include?(v[0])

    ref =
      case v[0]
      when '_func' then true
      when '_proc' then v[1]['proc'] != o
      when '_task' then v[1]['task'] != o
      else false
      end

    v[1]['oref'] ||= v[1]['ref'] if ref && v[1]['ref']
    v[1]['ref'] = o if ref

    v
  end

  def reheap(tree, heat)

    if ! heat.is_a?(Array)
      '_val'
    elsif tree && tree[1] == []
      '_val'
    elsif heat[0] == '_proc'
      heat[1]['proc']
    elsif heat[0] == '_func'
      'apply'
    elsif heat[0] == '_task'
      'task'
    elsif Flor.is_tree_head_tree?(tree)
      '_happly'
    else
      '_val'
    end
  end

  def tree

    lookup_tree(nid)
  end

  def fei

    "#{exid}-#{nid}"
  end

  def on_error_parent

    oe = @node['on_error']
    return self if oe && oe.any?

    pn = parent_node
    return Flor::Node.new(@executor, pn, @message).on_error_parent if pn

    nil
  end

  def to_procedure

    Flor::Procedure.new(@executor, @node, @message)
  end

  def descendant_of?(nid, on_self=true)

    return on_self if self.nid == nid && on_self != nil

    i = self.nid

    loop do
      node = @executor.node(i)
      break unless node
      i = node['parent']
      return true if i == nid
    end

    false
  end

  protected

  def subtree(tree, pnid, nid)

    pnid = Flor.master_nid(pnid)
    nid = Flor.master_nid(nid)

    return nil unless nid[0, pnid.length] == pnid
      # maybe failing would be better

    cid = nid[pnid.length + 1..-1]

    return nil unless cid
      # maybe failing would be better

    cid.split('_').each { |cid| tree = tree[1][cid.to_i] }

    tree
  end

  def parent_node(node=@node)

    @execution['nodes'][node['parent']]
  end

  def parent_node_tree(node=@node)

    lookup_tree(node['parent'])
  end

  def is_ancestor_node?(nid, node=@node)

    return false unless node
    return true if node['nid'] == nid

    is_ancestor_node?(nid, parent_node(node))
  end

  #def closure_node(node=@node)
  #  @execution['nodes'][node['cnid']]
  #end

  def lookup_in_node(pth)

    Flor.deep_get(@node, pth)
  end

  def lookup_dvar(mod, key)

    if mod != 'd' && Flor::Procedure[key]
      return [ '_proc', { 'proc' => key }, -1 ]
    end

    l = @executor.unit.loader
    vdomain = @node['vdomain']
      #
    if l && vdomain != false
      v = l.variables(vdomain || domain).fetch(key) { :no }
      return v unless v == :no
    end

    if mod != 'd' && @executor.unit.has_tasker?(@executor.exid, key)
      return [ '_task', { 'task' => key }, -1 ]
    end

    nil
  end

  def lookup_var(node, mod, key, pth)

    val = do_lookup_var(node, mod, key)

    r = Flor.deep_get(val, pth)

    return r unless r.is_a?(Symbol)
    return nil unless r.to_s.count('.') < pth.count('.')

    rs = r.to_s.split('.')

    qualifier = 'key'
    tail = rs.pop
    qualifier, tail = [ 'index', tail.to_i ] if tail.match(/\A\d+\z/)

    body = [ key, *rs ].join('.')

    fail IndexError.new(
      "no #{qualifier} #{tail.inspect} in variable #{body.inspect}")
  end

  def do_lookup_var(node, mod, key)

    return lookup_dvar(mod, key) if node == nil || mod == 'd'

    pnode = parent_node(node)
    #cnode = closure_node(node)

    if mod == 'g'
      vars = node['vars']
      return do_lookup_var(pnode, mod, key) if pnode
      return vars[key] if vars
      #return do_lookup_var(cnode, mod, key) if cnode
      fail "node #{node['nid']} has no vars and no parent"
    end

    vars = node['vars']

    return vars[key] if vars && vars.has_key?(key)

    if cnid = node['cnid']
      cvars = (@execution['nodes'][cnid] || {})['vars']
      return cvars[key] if cvars && cvars.has_key?(key)
    end
      #
      # look into closure, just one level deep...

    do_lookup_var(pnode, mod, key)
  end

  def lookup_var_name(node, val)

    return nil unless node

    vars = node['vars']
    k, _ = vars && vars.find { |k, v| v == val }
    return k if k

    lookup_var_name(parent_node(node), val)
  end

  def lookup_tag(mod, key)

    nids =
      @execution['nodes'].inject([]) do |a, (nid, n)|
        a << nid if n['tags'] && n['tags'].include?(key)
        a
      end

    nids.empty? ? [ '_nul', nil, -1 ] : nids
  end

  def lookup_field(mod, key_and_path)

    r = Flor.deep_get(payload.current, key_and_path)
    r.is_a?(Symbol) ? nil : r
  end

  def key_split(key) # => category, mode, key

    m = key.match(
      /\A(?:([lgd]?)((?:v|var|variable)|w|f|fld|field|t|tag)\.)?(.+)\z/)

    #fail ArgumentError.new("couldn't split key #{key.inspect}") unless m
      # spare that

    ca = (m[2] || 'v')[0, 1]
    mo = m[1] || ''
    ke = m[3]

    [ ca, mo, ke ]
  end
end

