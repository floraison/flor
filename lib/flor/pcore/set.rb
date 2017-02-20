
class Flor::Pro::Set < Flor::Procedure

  names %w[ set setr ]

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child
  end

  def receive_non_att

    @node['ref'] ||= payload['ret']

    super
  end

  def receive_last

    set_value(@node['ref'], payload['ret'])

    payload['ret'] =
      if tree[0] == 'setr' || @node['ref'] == 'f.ret'
        payload['ret']
      else
        node_payload_ret
      end

    reply
  end
end

#  protected
#
#  def splat(ks, vs)
#
#    ks.inject(0) { |off, k|
#      if k[0, 1] == '*'
#        #p({ off: off, k: k, ks: ks[off + 1..-1], vs: vs[off..-1] })
#        l = vs.length - ks.length + 1
#        set_value(k[1..-1], vs[off, l])
#        off + l
#      else
#        set_value(k, vs[off])
#        off + 1
#      end
#    }
#  end
  #
  # TODO need a splat a some point

