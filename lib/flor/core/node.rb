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

  def payload
    @message_payload ||= Payload.new(self, :message)
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

  def lookup(name)

    cat, mod, key = key_split(name)
    key, pth = key.split('.', 2)

    val =
      if [ cat, mod, key ] == [ 'v', '', 'node' ]
        @node
      elsif cat == 'v'
        lookup_var(@node, mod, key)
      else
        lookup_field(mod, key)
      end

    if pth
      Flor.deep_get(val, pth)[1]
    else
      val
    end
  end

  class Expander < Flor::Dollar

    def initialize(n); @node = n; end

    def lookup(k)

      return @node.nid if k == 'nid'
      return @node.exid if k == 'exid'
      return Flor.tstamp if k == 'tstamp'

      @node.lookup(k)
    end
  end

  def expand(s)

    return s unless s.is_a?(String)

    Expander.new(self).expand(s)
  end

  def deref(o)

    if o.is_a?(String)
      lookup(o)
    else
      o
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

#  def ascendancy
#
#    a = []
#    i = self.nid
#
#    loop do
#      node = @executor.node(i)
#      break unless node
#      a << node['parent']
#      i = a.last
#    end
#
#    a
#  end

  protected

  def subtree(tree, pnid, nid)

    pnid = Flor.master_nid(pnid)
    nid = Flor.master_nid(nid)

    return nil unless nid[0, pnid.length] == pnid
      # maybe failing would be better

    nid[pnid.length + 1..-1].split('_').each { |cid| tree = tree[1][cid.to_i] }

    tree
  end

  def parent_node(node=@node)

    @execution['nodes'][node['parent']]
  end

  def parent_node_tree(node=@node)

    lookup_tree(node['parent'])
  end

  #def closure_node(node=@node)
  #  @execution['nodes'][node['cnid']]
  #end

  def lookup_dvar(mod, key)

    if mod != 'd' && Flor::Procedure[key]
      return [ '_proc', key, -1 ]
    end

    if mod != 'd' && @executor.unit.tasker.has_tasker?(@executor.exid, key)
      return [ '_task', key, -1 ]
    end

    l = @executor.unit.loader
    dvars = @node['dvars']
      #
    if l && dvars != false
      return l.variables(dvars || domain)[key]
    end

    nil
  end

  def lookup_var(node, mod, key)

    return lookup_dvar(mod, key) if node == nil || mod == 'd'

    pnode = parent_node(node)
    #cnode = closure_node(node)

    if mod == 'g'
      vars = node['vars']
      return lookup_var(pnode, mod, key) if pnode
      return vars[key] if vars
      #return lookup_var(cnode, mod, key) if cnode
      fail "node #{node['nid']} has no vars and no parent"
    end

    vars = node['vars']

    return vars[key] if vars && vars.has_key?(key)

    if cnid = node['cnid'] # look into closure
      cvars = (@execution['nodes'][cnid] || {})['vars']
      return cvars[key] if cvars && cvars.has_key?(key)
    end

    lookup_var(pnode, mod, key)
  end

  def lookup_field(mod, key)

    Flor.deep_get(payload.current, key)[1]
  end

  def key_split(key) # => category, mode, key

    m = key.match(/\A(?:([lgd]?)((?:v|var|variable)|w|f|fld|field)\.)?(.+)\z/)

    #fail ArgumentError.new("couldn't split key #{key.inspect}") unless m
      # spare that

    ca = (m[2] || 'v')[0, 1]
    mo = m[1] || ''
    ke = m[3]

    [ ca, mo, ke ]
  end
end

