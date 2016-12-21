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


class Flor::Procedure < Flor::Node

  def self.inherited(subclass)

    (@@inherited ||= []) << subclass
  end

  def self.[](name)

    @@inherited.find { |k| k.names && k.names.include?(name) }
  end

  class << self

    def names(*names)

      names = names.flatten
      @names = names if names.any?

      @names
    end

    alias :name :names
  end

  def pre_execute

    # empty default implementation
  end

  def trigger_on_error

    @message['on_error'] = true

    @node['status'] =
      'triggered-on-error'
    @node['on_receive_last'] =
      apply(@node['on_error'].shift, [ @message ], tree[2])

    nids = @node['cnodes']

    if nids && nids.any?
      cancel_children
    else
      do_receive # which should trigger 'on_receive_last'
    end
  end

  def debug_tree

    Flor.print_tree(tree, nid)
  end

  def debug_msg

    Flor.detail_msg(@executor, message)
  end

  protected

  def children

    tree[1]
  end

  def att_children

    children.select { |c| c[0] == '_att' }
  end

  def non_att_children

    children.select { |c| c[0] != '_att' }
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

  def execute_child(index=0, sub=nil, duplicate_payload=false)

    return reply \
      if index < 0 || ! tree[1].is_a?(Array) || tree[1][index] == nil

    cnid = Flor.child_nid(nid, index, sub || 0)

    (@node['cnodes'] ||= []) << cnid

    pl = @message['payload']
    pl = Flor.dup(pl) if duplicate_payload

    reply(
      'point' => 'execute',
      'nid' => cnid,
      'tree' => tree[1][index],
      'payload' => pl)
  end

#  # turns ```sleep "1y"``` into ```sleep _unkeyed: "1y"```
#  #
#  def rewrite_first_unkeyed_att
#
#    # TODO is that really necessary?
#
#    ci =
#      children.index { |c|
#        c[0] == '_att' && c[1].size == 1 && c[1].first[0] != '_'
#      }
#    return unless ci
#
#    t = tree
#    cn = Flor.dup(t[1])
#    c = cn[ci][1].first
#    cn[ci] = [ '_att', [ [ '_unkeyed', [], c[2] ], c ], c[2] ]
#
#    @node['tree'] = [ t[0], cn, t[1] ]
#  end

  def is_symbol_tree?(t)

    t[0].is_a?(String) && t[1] == []
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

  def stringify_first_child

    c = non_att_children.first
    return unless c
    return unless c[1] == [] && c[0].is_a?(String)

    ci = children.index(c)
    cn = Flor.dup(children)
    cn[ci] = [ '_sqs', c[0], c[2] ]

    @node['tree'] = [ tree[0], cn, tree[2] ]
  end

  def execute

    receive
  end

  def do_receive

    if @node['status']
      receive_when_status
    else
      receive
    end
  end

  def receive_when_status

    @node.delete('status') if @node['status'] == 'continued'

    ns = @node['cnodes']
    ns.delete(from) if ns

    orl = (ns == []) && @node.delete('on_receive_last')

    orl || reply
  end

  def receive

    cnode = @node['cnodes'] ? @node['cnodes'].delete(from) : false

    @fcid = point == 'receive' ? Flor.child_id(from) : nil
    @ncid = (@fcid || -1) + 1

    return receive_first if @fcid == nil

    child = children[@fcid]

    return receive_att if child && child[0] == '_att'

    receive_non_att
  end

  def receive_first

    return receive_last_att if children[0] && children[0][0] != '_att'
    execute_child(@ncid)
  end

  def receive_att

    nctree = children[@ncid]

    return receive_last_att if nctree == nil || nctree[0] != '_att'
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

    reply
  end

  # Used by 'cursor' (and 'loop') when
  # ```
  # cursor 'main'
  #   # is equivalent to:
  # cursor tag: 'main'
  # ```
  #
  def receive_unkeyed_tag_att

    ret = @message['payload']['ret']
    ret = Array(ret).flatten
    ret = nil unless ret.any? && ret.all? { |e| e.is_a?(String) }

    return [] unless ret

    (@node['tags'] ||= []).concat(ret)

    reply('point' => 'entered', 'nid' => nid, 'tags' => ret)
  end

  def reply(h={})

    m = {}
    m['point'] = 'receive'
    m['exid'] = exid
    m['nid'] = parent
    m['from'] = nid

    m['sm'] = @message['m']

    ret = :no
    ret = h.delete('ret') if h.has_key?('ret')

    m['payload'] = payload.current

    m.merge!(h)

    m['payload']['ret'] = ret if ret != :no

    [ m ]
  end

  def queue(h); reply(h); end

  def error_reply(o)

    reply('point' => 'failed', 'error' => Flor.to_error(o))
  end

  def schedule(h)

    h['point'] ||= 'schedule'
    h['payload'] ||= {}
    h['nid'] ||= nid

    reply(h)
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

      b, v = Flor.deep_set(node['vars'], k, v)

      return v if b
    end

    fail IndexError.new("couldn't set var #{mode}v.#{k}")
  end

  def set_field(k, v)

    success, value = Flor.deep_set(payload.copy, k, v)

    fail IndexError.new("couldn't set field #{k}") unless success

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
    ani = anid ? Flor.sub_nid(fni, @executor.counter_next('subs')) : fni
      # the "trap" apply doesn't want a subid generated before it triggers...

    cni = fun[1]['cnid'] # closure nid

    t = lookup_tree(fni)

    if cid = fun[1]['cid']
      t = [ 'define', t[1][cid..-1], t[2] ]
    end

    sig = t[1].select { |c| c[0] == '_att' }
    sig = sig.drop(1) if t[0] == 'define'

    vars = {}
    vars['arguments'] = args # should I dup?
    sig.each_with_index do |att, i|
      key = att[1].first[0]
      vars[key] = args[i]
    end

    ms = reply(
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

  def cancel_nodes(nids)

    (nids || [])
      .collect { |i| reply('point' => 'cancel', 'nid' => i, 'from' => nid) }
      .flatten(1)
  end

  def cancel_reply # "cancel" as a noun

    reply(
      'cause' => 'cancel',
      'payload' => @message['payload'] || @node['payload'])
  end

  def cancel_children

    cancel_nodes(@node['cnodes'])
  end

  def cancel

    nids = @node['cnodes']

    if nids && nids.any?
      cancel_children
    else
      cancel_reply
    end
  end
end

# A namespace for primitive procedures
#
module Flor::Pro; end

