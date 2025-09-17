# frozen_string_literal: true


class Flor::Pro::Del < Flor::Procedure
  #
  # Removes a field or a variable.
  #
  # ```
  # sequence
  #   del f.a  # blanks field 'a' from the payload
  #   del a    # blanks variable 'a'
  # ```
  #
  # Returns the value held in the field or variable or `null` else.
  #
  # `del` will raise an error if the target field cannot be reached,
  # but `delf` will not raise and simply return `null`.

  names %w[ del delf ]

  def pre_execute

    unatt_unkeyed_children
    rerep_children

    @node['refs'] = []
  end

  def receive_non_att

    ft = tree[1][@fcid] || []

    if ft[0] == '_rep'
      @node['refs'] << payload['ret']
    else
      payload['ret'] = node_payload_ret
    end

    super
  end

  def receive_last

    ret = nil

    @node['refs'].each do |ref|

      ret = (lookup_value(ref) rescue nil)
      begin
        unset_value(ref)
      rescue
        raise unless tree[0] == 'delf'
      end
    end

    wrap('ret' => ret)
  end

  protected

  def rerep_children

    t = tree

    cn = t[1]
      .collect { |ct|
        hd, cn, ln = ct
        if hd == '_ref'
          [ '_rep', cn, ln ]
        elsif hd == '_dqs'
          [ '_rep', [ ct ], ln ]
        elsif Flor.is_single_ref_tree?(ct)
          [ '_rep', [ [ '_sqs', hd, ln ] ], ln ]
        else
          ct
        end }

    @node['tree'] = [ t[0], cn, t[2] ] if cn != t[1]
  end
end

