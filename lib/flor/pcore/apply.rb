# frozen_string_literal: true

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
  # It is usually used implicitly, as in
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
  #
  # ## rubyesque blocks
  #
  # In Ruby, one case pass a block on a function call:
  # ```ruby
  # def f(i)
  #   i * yield
  # end
  # p f(5) { |j| 10 }
  # ```
  # which just prints `50`.
  #
  # This can be achieved in flor like this:
  # ```
  # define f i
  #   * i (yield _)
  # f 5
  #   10
  # echo f.ret
  # ```
  #
  # If one needs to have a "block" with parameters, it can be done by having
  # an anonymous function definition has the only thing in the block:
  # ```
  # define f i
  #   + i (yield i)
  # f 5
  #   def j
  #     * 3 j
  # f.ret #=> 20
  # ```
  #
  # ## see also
  #
  # define.

  name 'apply'

  def pre_execute

    @node['atts'] = []
  end

  def receive

    return wrap_reply if from && from == @node['applied']

    super
  end

  def receive_last_att

    return do_apply unless tree[1][@ncid]

    rewrite_block_into_function

    super
  end

  def receive_last

    do_apply
  end

  protected

  def do_apply

    args = @node['atts']
    nht = @node['heat']

    src =
      Flor.is_proc_tree?(nht) && nht[1]['proc'] == 'apply' ?
      args.shift[1] :
      nht

    args << [ 'yield', payload_ret ] \
      if ! from_att? && Flor.is_func_tree?(payload_ret)

    ms = apply(src, args, tree[2])

    @node['applied'] = ms.first['nid']

    ms
  end

  def rewrite_block_into_function

    t = tree
    cn = t[1][@ncid..-1]
    c0 = cn[0]

    return if cn.size == 1 && %w[ def fun ].include?(c0[0])
      #
      # if the single child is a "def" or "fun", no need to rewrite,
      # that single child function becomes the block

    bt = [ 'def', cn, t[2] ]
    t[1] = (@fcid ? t[1][0..@fcid] : []) + [ bt ]

    @node['tree'] = t
  end
end

