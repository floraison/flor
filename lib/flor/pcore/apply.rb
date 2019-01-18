
class Flor::Pro::Apply < Flor::Procedure
  #
  # Applies a function.
  #
  # ```
  # sequence
  #   define sum a b
  #     +
  #       a
  #       b
  #   apply sum 1 2
  # ```
  #
  # It is usually used implicitely, as in
  # ```
  # sequence
  #   define sum a b
  #     +
  #       a
  #       b
  #   sum 1 2
  # ```
  # where flor figures out by itself it has to use this "apply" procedure
  # to call the function.

  name 'apply'

  def pre_execute

    @node['atts'] = []
  end

  def receive

    return wrap_reply if from && from == @node['applied']

    super
  end

  def receive_last_att

    args = @node['atts']
    nht = @node['heat']

    src =
      Flor.is_proc_tree?(nht) && nht[1]['proc'] == 'apply' ?
      args.shift[1] :
      nht

    bfun = make_block_func
    args << [ '_block', bfun ] if bfun

    ms = apply(src, args, tree[2])

    @node['applied'] = ms.first['nid']

    ms
  end

  protected

  def make_block_func

    t = tree
    ncid = @fcid + 1

    return nil unless t[1][ncid]

    @node['tree'] = t

    cn = t[1][ncid..-1]
    tr = [ 'def', cn, cn[0][2] ]
    t[1] = t[1][0..@fcid]

    [ '_func',
      { 'nid' => Flor.child_nid(nid, @fcid + 1),
        'tree' => tr },
      tree[2] ]
  end
end

