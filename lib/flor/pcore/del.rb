# frozen_string_literal: true

require 'flor/pcore/set'


class Flor::Pro::Del < Flor::Pro::Set
  #
  # Removes a field or a variable.
  #
  # ```
  # sequence
  #   del f.a  # blanks field 'a' from the payload
  #   del a    # blanks variable 'a'
  # ```
  #
  # Returns the value held in the field or variable or null else.

  names %w[ del ]

#  def pre_execute
#
#    unatt_unkeyed_children
#    reref_children
#
#    #@node['single_child'] = (non_att_children.count == 1)
#
#    rep_children
#
#    @node['refs'] = []
#  end
#
#  def execute_child(index=0, sub=nil, h=nil)
#
#    payload['ret'] = node_payload_ret \
#      if children[index]
#
#    super(index, sub, h)
#  end

#  def receive_non_att
#
#    ft = tree[1][@fcid] || []
#
#    if ft[0] == '_rep' || (Flor.is_string_tree?(ft) && ! last_receive?)
#      @node['refs'] << payload['ret']
#    elsif ft[0] == '_ref' &&
#      ft[1].size == 2 &&
#      ft[1][0][0, 2] == [ '_sqs', 'f' ] && ft[1][1][0, 2] == [ '_sqs', 'ret' ]
#    then
#      payload['ret'] = node_payload_ret
#    end
#
#    super
#  end

  def receive_last

    ret = nil

    @node['refs'].each do |ref|
      ret = lookup_value(ref)
      unset_value(ref)
    end

    payload['ret'] = ret

    wrap

#    case refs.size
#    when 0 then 0
#    when 1 then set_value(refs.first, ret)
#    else splat_value(refs, ret)
#    end
#
#    payload['ret'] =
#      if tree[0] == 'setr' || refs_include_f_ret?
#        ret
#      else
#        node_payload_ret
#      end
#    wrap
  end

  protected

#  def refs_include_f_ret?
#
#    !! @node['refs']
#      .find { |ref|
#        ref.length == 2 &&
#        ref[1] == 'ret' &&
#        ref[0].match(/\Af(ld|ield)?\z/) }
#  end
#
#  def reref_children
#
#    t = tree
#
#    cn = t[1]
#      .collect { |ct|
#        hd, cn, ln = ct
#        if hd == '_dqs'
#          [ '_ref', [ ct ], ln ]
#        elsif Flor.is_single_ref_tree?(ct)
#          [ '_ref', [ [ '_sqs', hd, ln ] ], ln ]
#        else
#          ct
#        end }
#
#    @node['tree'] = [ t[0], cn, t[2] ] if cn != t[1]
#  end
#
#  def rep_children
#
#    t = tree
#    li = t[1].length - 1
#
#    cn = t[1]
#      .each_with_index
#      .collect { |ct, i|
#        hd, cn, ln = ct
#        if hd == '_ref' && (@node['single_child'] || li != i)
#          [ '_rep', cn, ln ]
#        else
#          ct
#        end }
#
#    @node['tree'] = [ t[0], cn, t[2] ] if cn != t[1]
#  end
end

