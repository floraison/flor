
class Flor::Pro::Set < Flor::Procedure
  #
  # sets a field or a variable.
  #
  # ```
  # sequence
  #   set f.a 1        # sets the value `1` in the field 'a'
  #   set a false      # sets the `false` in the variable 'a'
  #   set v.b [ 1 2 ]  # sets `[ 1, 2 ]` in the variable 'b'
  #   set v.c.0 -1     # sets `-1` in first slot of the array in var 'c'
  # ```
  #
  # When set has a single child, it uses as value to copy the content of
  # payload.ret.
  #
  # ```
  # sequence
  #   "hello world"
  #   set a
  # #
  # # is equivalent to
  # #
  # sequence
  #   set a "hello world"
  # ```
  #
  # ## splat
  #
  # ```
  # sequence
  #   set a b___ c
  #     [ 0 1 2 3 ]
  #       # ==> a: 0, b: [ 1, 2 ], c: 3
  #   set d e__2 f
  #     [ 4 5 6 7 8 ]
  #       # ==> d: 4, e: [ 5, 6 ], f: 7
  #   set __2 g h
  #     [ 9 10 11 12 13 ]
  #       # ==> g: 11, h: 12
  #       # `__` is not prefixed by a var name, so it justs discard
  #       # what it captures
  #   set i j___
  #     [ 14 15 16 17 18 19 ]
  #       # ==> i: 14, j: (15..19).to_a
  #   set "k__$(c)" l
  #     [ 20 21 22 23 24 ]
  #       # ==> k: [ 20, 21, 22 ], l: 23
  # ```
  #
  # ## "setr"
  #
  # "set", before terminating its execution carefully resets the payload.ret
  # value to what it was right before it started executing.
  # "setr" is a version of "set" that doesn't care and leave payload.ret to
  # value set by its last child (usually the value set).
  #
  # ```
  #   sequence
  #     123         # payload.ret is set to `123`
  #     set a 456   # var 'a' is set to 456, payload.ret is reset to `123`
  #     setr b 789  # var 'b' is set to `789`, payload.ret as well
  # ```

  names %w[ set setr ]

  def pre_execute

    unatt_unkeyed_children

    t = tree
    #cl = t[1].length

    children, non_att_count, changed =
      t[1]
        .each_with_index
        .inject([ [], 0, false ]) { |(cn, nac, ced), (t, i)|
#p [ [ cn, nac, ced ], [ t, i ] ]
          nac = nac + 1 if t[0] != '_att'
          if t[0] == '_ref'
            cn << [ '_rep', t[1], t[2] ]
            ced = true
          else
            cn << t
          end
          [ cn, nac, ced ] }

    @node['single_child'] = (non_att_count == 1)
    @node['tree'] = [ t[0], children, t[2] ] if changed

    @node['refs'] = []
  end

  def execute_child(index=0, sub=nil, h=nil)

    payload['ret'] = node_payload_ret \
      if children[index]

    super(index, sub, h)
  end

  def receive_non_att

#    ret = payload['ret']
#    last = ! @node['single_child'] && (@fcid + 1) == children.size
#
#    @node['refs'] << ret if ! last && ret.is_a?(String)

    fromt = tree[1][@fcid] || []
    @node['refs'] << payload['ret'] if fromt[0] == '_rep'

    super
  end

  def receive_last

    ret = payload['ret']

    set_value(@node['refs'].first, ret)
      # TODO splat!

    payload['ret'] =
      if tree[0] == 'setr'# || @node['refs'].last == 'f.ret'
        ret
      else
        node_payload_ret
      end

    wrap
#    ret = @node['single_child'] ? node_payload_ret : payload['ret']
#
#    if @node['refs'].size == 1
#      set_value(@node['refs'].first, ret)
#    else
#      Flor.splat(@node['refs'], ret).each { |k, v| set_value(k, v) }
#    end
#
#    payload['ret'] =
#      if tree[0] == 'setr' || @node['refs'].last == 'f.ret'
#        ret
#      else
#        node_payload_ret
#      end
#
#    wrap_reply
  end
end

