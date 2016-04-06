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

  def self.names(*names)

    names.flatten.each { |n| Flor::Executor.procedures[n] = self }
  end

  class << self; alias :name :names; end

  protected

  def children

    tree[1]
  end

  def execute_child(index, sub=0)

    return reply unless tree[1][index]

    reply(
      'point' => 'execute',
      'nid' => Flor.child_nid(nid, index, sub),
      'tree' => tree[1][index])
  end

  def sequence_receive

    i = @message['point'] == 'execute' ? 0 : Flor.next_child_id(from)

    if i > 0 && rets = @node['rets']
      rets << Flor.dup(payload['ret'])
      @node['mtime'] = Flor.tstamp
    end

    execute_child(i)
  end

  def reply(h={})

    m = {}
    m['point'] = 'receive'
    m['exid'] = exid
    m['nid'] = parent
    m['from'] = nid
    m['payload'] = payload

    ret = :no
    ret = h.delete('ret') if h.has_key?('ret')

    m.merge!(h)

    m['payload']['ret'] = ret if ret != :no

    [ m ]
  end

  def error_reply(o)

    reply('point' => 'failed', 'error' => Flor.to_error(o))
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

    success, value = Flor.deep_set(payload, k, v)

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

  def counter_next(key)

    @execution['counters'][key.to_s] += 1
  end

  def apply(fun, args, line)

    fni = fun[1]['nid'] # fun nid
    cni = fun[1]['cnid'] # closure nid
    ani = Flor.sub_nid(fni, counter_next('sub')) # applied nid

    t = lookup_tree_anyway(fni)
    sig = t[1].select { |c| c[0] == '_att' }
    sig = sig.drop(1) if t[0] == 'define'

    vars = {}
    vars['arguments'] = args # should I dup?
    sig.each_with_index do |att, i|
      key = att[1].first[0]
      vars[key] = args[i]
    end

    reply(
      'point' => 'execute',
      'nid' => ani,
      'tree' => [ '_apply', t[1], line ],
      'vars' => vars,
      'cnid' => cni)
  end
end

# A namespace for primitive procedures
#
module Flor::Pro; end

