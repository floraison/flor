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

  def initialize(execution, node, message)

    @execution = execution
    @node = node
    @message = message
  end

  def exid; @execution['exid']; end
  def nid; @node['nid']; end
  def parent; @node['parent']; end
  def from; @message['from']; end
  def attributes; tree[1]; end
  def payload; @message['payload']; end

  def lookup_tree(nid)

    node = @execution['nodes'][nid]
    return nil unless node

    tree = node['tree']
    return tree if tree

    tree = lookup_tree(node['parent'])
    return nil unless tree

    tree[1][Flor.child_id(nid)]
  end

  def lookup_tree_anyway(nid)

    tree = lookup_tree(nid)
    return tree if tree

    tree = lookup_tree_anyway(Flor.parent_id(nid))

    tree[3][Flor.child_id(nid)]
  end

  def lookup(name)

    cat, mod, key = key_split(name)
    key, pth = key.split('.', 2)

    val = cat == 'v' ? lookup_var(@node, mod, key) : lookup_field(mod, key)
    pth ? Flor.deep_get(val, pth)[1] : val
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
    elsif Flor.is_string_val?(o)
      lookup(o[1]['v'])
    else
      o
    end
  end

  protected

  def resolve(o)

    if Flor.is_val?(o)
      Flor.de_val(o)
    else
      deref(expand(o))
    end
  end

  def tree

    lookup_tree(nid)
  end

  def parent_node(node)

    @execution['nodes'][node['parent']]
  end

  def lookup_dvar(mod, key)

    return nil if mod == 'd' # FIXME

    Flor::Executor.procedures[key] ?
      [ 'val', { 't' => 'procedure', 'v' => key }, -1, [] ] :
      nil
  end

  def lookup_var(node, mod, key)

    return lookup_dvar(mod, key) if node == nil || mod == 'd'

    pnode = parent_node(node)

    if mod == 'g'
      return node['vars'][key] if pnode == nil
      return lookup_var(pnode, mod, key)
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

    Flor.deep_get(payload, key)[1]
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

