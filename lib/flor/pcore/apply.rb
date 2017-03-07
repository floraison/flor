
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

    return reply if from && from == @node['applied']

    super
  end

  def receive_last

    args = @node['atts'].collect(&:last)

    nht = @node['heat']

    src =
      Flor.is_proc_tree?(nht) && nht[1]['proc'] == 'apply' ?
      args.shift :
      nht

    ms = apply(src, args, tree[2])

    @node['applied'] = ms.first['nid']

    ms
  end
end

