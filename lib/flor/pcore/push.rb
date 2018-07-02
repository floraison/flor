
class Flor::Pro::Push < Flor::Procedure
  #
  # Pushes a value into an array (in a variable or a field).
  #
  # ```
  # sequence
  #   set a []
  #   set f.a []
  #   push a 1
  #   push f.a 2
  # ```
  #
  # ```
  # sequence
  #   set o { a: [], b: 3 }
  #   7
  #   push o.a  # will push value 7 (payload.ret) into array at 'o.a'
  # ```
  #
  # ```
  # push
  #   myarray    # the 1st child is expected to hold the reference to the array
  #   do_this _
  #   do_that _
  #   + 1 2      # the last child should hold the value to push
  # ```
  #
  # ## "pushr"
  #
  # Following ["set"](set.md) and "setr", "push", upon beginning its execution
  # will keep the incoming payload.ret and restore it to that value right
  # before finishing its execution. "pushr" will not do that, it will leave
  # the payload.ret as is, that is, set to the value that was just pushed to
  # the array.

  names %w[ push pushr ]

  def pre_execute

    unatt_unkeyed_children
    rep_first_child
  end

  def receive_non_att

    if ! @node['arr']
      @node['arr'] = payload['ret']
    else
      @node['val'] = payload['ret']
    end

    super
  end

  def receive_last

    push(@node.has_key?('val') ? @node['val'] : node_payload_ret)

    payload['ret'] = node_payload_ret \
      unless tree[0] == 'pushr'

    wrap_reply
  end

  protected

  def rep_first_child

    hd, cn, ln = tree

    ri = cn.index { |ct| ct[0] == '_ref' || Flor.is_single_ref_tree?(ct) }

    return unless ri

    cn1 = cn.dup
    rt = cn[ri]

    cn1[ri] =
      if rt[0] == '_ref'
        [ '_rep', rt[1], rt[2] ]
      else
        s, _, l = rt
        [ '_rep', [ [ '_sqs', s, l ] ], l ]
      end

    @node['tree'] = [ hd, cn1, ln ]
  end

  def push(val)

    arr = lookup_value(@node['arr'])

    fail Flor::FlorError.new(
      "cannot push to given target (#{arr.class})", self
    ) unless arr.respond_to?(:push)

    arr.push(val)
  end
end

