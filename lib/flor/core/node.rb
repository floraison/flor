
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
    def dup_current
      current ? current.dup : nil
    end
    def merge(h)
      current.merge(h)
    end

    def ret
      self['ret']
    end
    def ret=(v)
      self['ret'] = v
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

  def child_id; Flor.child_id(@node['nid']); end

  def domain; Flor.domain(@execution['exid']); end

  def point; @message['point']; end
  def from; @message['from']; end

  def cnodes; @node['cnodes']; end
  def cnodes_any?; cnodes && cnodes.any?; end
  def cnodes_empty?; cnodes.nil? || cnodes.empty?; end

  def payload
    @message_payload ||= Payload.new(self, :message)
  end

  def node_status
    @node['status'].last
  end
  def node_status_flavour
    node_status['flavour']
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

  def payload_ret
    message['payload']['ret']
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

  def lookup_value(path)

    original_path = path

    path =
      case path
      when '*' then [ path ]
      when String then Dense::Path.make(path).to_a
      else path
      end

    path.unshift('v') \
      if path.length < 2

    case path.first
    when /\Af(?:ld|ield)?\z/
      lookup_field(nil, path[1..-1]) # mod -> nil...
    when /\At(?:ag)?\z/
      lookup_tag(nil, path[1])
    when /\A([lgd]?)v(?:ar|ariable)?\z/
      return @message['__head'][1] if path[1] == '__head'
      lookup_var(@node, $1, path[1], path[2..-1])
    when 'node'
      lookup_in_node(path[1..-1])
    when 'exe', 'execution'
      lookup_in_execution(path[1..-1])
    else
      lookup_var(@node, '', path[0], path[1..-1])
    end

  rescue KeyError => ke

    class << ke; attr_accessor :original_path, :work_path; end
    ke.original_path = original_path
    ke.work_path = path

    raise
  end

  # Returns the referenced tree.
  # Returns nil if not found.
  #
  def deref(s)

    v = lookup_value(s)

    if Flor.is_tree?(v)

      ref =
        case v[0]
        when '_func' then true
        when '_proc' then v[1]['proc'] != s
        when '_tasker' then v[1]['tasker'] != s
        else false
        end

      v[1]['oref'] ||= v[1]['ref'] if ref && v[1]['ref']
      v[1]['ref'] = s if ref

      v

    else

      [ '_val', v, tree[2] ]
    end

  rescue KeyError => ke

    nil
  end

  def reheap(tree, heat)

    case
    when ! heat.is_a?(Array) then '_val'
    when tree && tree[1] == [] then '_val'
    when heat[0] == '_proc' then heat[1]['proc']
    when heat[0] == '_func' then 'apply'
    when heat[0] == '_tasker' then 'task'
    else '_val'
    end
  end

  def tree

    lookup_tree(nid)
  end

  def fei

    "#{exid}-#{nid}"
  end

  def to_procedure_node

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

  def on_error_parent

    if (@node['on_error'] || []).find { |criteria, _| match_on?(criteria) }
      return self
    end

    if pn = parent_node
      return Flor::Node.new(@executor, pn, @message).on_error_parent
    end

    nil
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

    cid.split('_').each { |id| tree = tree[1][id.to_i] }

    tree
  end

  def parent_node(node=@node)

    @execution['nodes'][node['parent']]
  end

  def parent_node_tree(node=@node)

    lookup_tree(node['parent'])
  end

  def parent_node_procedure(node=@node)

    Flor::Procedure.make(@executor, parent_node(node), @message)
  end

  def is_ancestor_node?(nid, node=@node)

    return false unless node
    return true if node['nid'] == nid

    is_ancestor_node?(nid, parent_node(node))
  end

  #def closure_node(node=@node)
  #  @execution['nodes'][node['cnid']]
  #end

  def lookup_in_node(path)

    Dense.fetch(@node, path)
  end

  def lookup_in_execution(path)

    if path == %w[ domain ]
      Flor.domain(@execution['exid'])
    else
      Dense.fetch(@execution, path)
    end
  end

  class PseudoVarContainer < Hash
    #
    # inherit from Hash so that Dense is quietly mislead
    #
    def initialize(type); @type = type; end
    #def has_key?(key); true; end
    def [](key); [ "_#{@type}", { @type => key }, -1 ]; end
  end
    #
  PROC_VAR_CONTAINER = PseudoVarContainer.new('proc')
  TASKER_VAR_CONTAINER = PseudoVarContainer.new('tasker')

  def escape(k)

    case k
    when '*', '.' then "\\#{k}"
    else k
    end
  end

  def lookup_var(node, mod, key, pth)

    c = lookup_var_container(node, mod, key)

    kp = [ key, pth ].reject { |x| x == nil || x.size < 1 }.join('.')
    kp = escape(kp)

    Dense.fetch(c, kp)

  rescue KeyError => ke

    m = "variable #{ke.miss[3].inspect} not found"
    m += " at #{Dense::Path.make(ke.miss[1]).to_s.inspect}" if ke.miss[1].any?

    raise ke.relabel(m)

  rescue IndexError => ie

    m =
      if ie.miss[1] == [ ie.miss[2] ]
         "variable #{ie.miss[2].inspect} not found"
      else
        pa = Dense::Path.make(ie.miss[1]).to_s.inspect
        ty = Flor.type(ie.miss[2])
        ke = ie.miss[3].inspect
        "variable at #{pa} is a #{ty}, it has no key #{ke}"
      end

    raise ie.relabel(m)

  #rescue TypeError => te # leave as is
  end

  def var_match?(vs, key)

    vs.each do |v|
      return true if v == key
      return true if v.is_a?(Regexp) && v =~ key
      # TODO fun call
    end

    false
  end

  def lookup_var_container(node, mod, key)

    return lookup_dvar_container(mod, key) if node == nil || mod == 'd'

    if vwl = node['vwlist']
      return lookup_dvar_container(mod, key) unless var_match?(vwl, key)
    end
    if vbl = node['vblist']
      return lookup_dvar_container(mod, key) if var_match?(vbl, key)
    end

    pnode = parent_node(node)
    vars = node['vars']

    if mod == 'g'
      return lookup_var_container(pnode, mod, key) if pnode
      return vars if vars
      fail "node #{node['nid']} has no vars and no parent"
    end

    return vars if vars && vars.has_key?(key)

    if cnid = node['cnid']
      cvars = (@execution['nodes'][cnid] || {})['vars']
      return cvars if cvars && cvars.has_key?(key)
    end
      #
      # look into closure, just one level deep...

    lookup_var_container(pnode, mod, key)
  end

  def lookup_dvar_container(mod, key)

    if mod != 'd' && Flor::Procedure[key]
      return PROC_VAR_CONTAINER
    end

    l = @executor.unit.loader
    vdomain = @node['vdomain']
      #
    if l && vdomain != false
      vars = l.variables(vdomain || domain)
      return vars if vars.has_key?(key)
    end

    if mod != 'd' && @executor.unit.has_tasker?(@executor.exid, key)
      return TASKER_VAR_CONTAINER
    end

    {}
  end

  def lookup_tag(mod, key)

    nids =
      @execution['nodes'].inject([]) do |a, (nid, n)|
        a << nid if n['tags'] && n['tags'].include?(key)
        a
      end

    nids.any? ? nids : nil
  end

  def lookup_field(mod, key_and_path)

    Dense.fetch(payload.current, key_and_path)
  end

  # Return true if the current @message matches on the given array of
  # criteria.
  #
  def match_on?(criteria)

    # AND, not OR, hence the true at the bottom

    criteria
      .each { |c|
        next if c == '*'
        return false unless send("match_on_#{c[0]}?", c) }

    true
  end

  def extract_on_info

    kla = @message['error']['kla']
    msg = @message['error']['msg']
    la = kla.split('::').last

    [ kla, la, msg ]
  end

  def match_on_class?(criterion)

    c1 = criterion[1]
    kla, la, _ = extract_on_info

    kla == c1 || la == c1
  end

  def match_on_string?(criterion)

    c1 = criterion[1]
    kla, la, msg = extract_on_info

    msg == c1 || kla == c1 || la == c1
  end

  def match_on_regex?(criterion)

    c1 = Flor.to_regex(criterion)
    kla, _, msg = extract_on_info

    msg =~ c1 || kla =~ c1
  end
end

