# frozen_string_literal: true

require 'flor/punit/m_ram'


# Parent class for "c-for-each" and "c-map"
#
class Flor::Pro::ConcurrentIterator < Flor::Procedure

  include Flor::Pro::ReceiveAndMerge

  def pre_execute

    @node['atts'] = []
    @node['args'] = []
    @node['col'] = nil

    reff_att_children
    unatt_unkeyed_children
  end

  def receive_non_att

    if Flor.same_sub?(nid, from)
      @node['args'] << payload['ret']
      super
    elsif @node['on_receive_nids'] && @node['on_receive_nids'][0] == from
      receive_from_receiver
    elsif @node['merging']
      receive_from_merger
    else
      receive_from_branch
    end
  end

  def receive_last

    t1 = tree[1]

    col = nil
    fun = nil
    refs = []
      #
    @node['args'].each_with_index do |a, i|
      if ( ! fun) && Flor.is_func_tree?(a)
        fun = a
      elsif ( ! col) && Flor.is_collection?(a)
        col = a
      else
        tt = t1[i]
        refs << Flor.ref_to_path(tt) if Flor.is_ref_tree?(tt)
      end
    end
      #
    col ||= node_payload_ret

    fail Flor::FlorError.new("collection not given to #{heap.inspect}", self) \
      unless Flor.is_collection?(col)
    return wrap('ret' => col) \
      unless Flor.is_func_tree?(fun)

    @node['col'] = col
    @node['cnt'] = col.size
    @node['fun'] = fun
    @node['refs'] = refs

    col
      .collect
      .with_index { |e, i|
        apply(fun, determine_iteration_args(col, i), tree[2]) }
      .flatten(1)
  end

  def add

    col = @node['col']
    elts = message['elements']

    fail Flor::FlorError.new(
      "cannot add branches to #{heap}", self
    ) unless elts

    tcol = Flor.type(col)

    x =
      if tcol == :object
        elts.inject(nil) { |r, e|
          next r if r
          t = Flor.type(e)
          t != :object ? t : r }
      else
        nil
      end
    fail Flor::FlorError.new("cannot add #{x} to object", self) \
      if x

    if tcol == :array
      col.concat(elts)
    else # tcol == :object
      elts.each { |e| col.merge!(e) }
    end

    cnt = @node['cnt']
    @node['cnt'] += elts.size

    pl = message['payload'] || node_payload.current

    elts
      .collect
      .with_index { |e, i|
        apply(
          @node['fun'], determine_iteration_args(col, cnt + i), tree[2],
          payload: Flor.dup(pl)) }
      .flatten(1)
  end

  protected

  def branch_count

    @node['col'].size
  end

  def determine_iteration_args(col, idx)

    refs = @node['refs'].dup

    args =
      if col.is_a?(Array)
        [ [ refs.shift || 'elt', col[idx] ] ]
      else
        e = col.to_a[idx]
        [ [ refs.shift || 'key', e[0] ], [ refs.shift || 'val', e[1] ] ]
      end
    args << [ refs.shift || 'idx', idx ]
    args << [ refs.shift || 'len', col.length ]

    args
  end

    # TODO: eventually move me up to Flor::Procedure, as Flor::Iterator might
    #       use me
    #
  def reff_att_children

    t = tree
    t1 = t[1]

    is = t1.each.with_index.inject([]) { |a, (tt, i)|
      a << i \
        if tt[0] == '_att' && tt[1].size == 1 && Flor.is_ref_tree?(tt[1][0])
      a }

    return if is.empty?

    is.each { |i| t1[i][1][0][0] = '_reff' }

    @node['tree'] = [ t[0], t1, *t[2..-1] ]
  end
end

