# frozen_string_literal: true

require 'flor/punit/m_receive_and_merge'


class Flor::Pro::Concurrence < Flor::Procedure
  #
  # Executes its children concurrently.
  #
  # ```
  # concurrence
  #   #
  #   # 'alpha' and 'bravo' will be tasked concurrently.
  #   #
  #   task 'alpha'
  #   task 'bravo'
  #   #
  #   # this concurrence will reply to its parent node when 'alpha' and 'bravo'
  #   # will both have replied.
  # ```
  #
  # ## payload merging
  #
  # by default, all the children replies are merged, with the first to
  # reply having the upper hand.
  # ```
  # concurrence
  #   set f.a 0
  #   set f.a 1
  #   set f.b 2
  # # will result in a payload of { a: 0, b: 2 } (first child replies first
  # # in those simplistic settings)
  # ```
  #
  # ## the expect: attribute
  #
  # Tells the concurrence how many children replies are expected at most.
  # Once that could is reached, remaining children are cancelled by default.
  # ```
  # concurrence expect: 1
  #   set f.a 0
  #   set f.b 1
  # ```
  #
  # ## the remaining: attribute
  #
  # As seen above, `expect:` will let the concurrence cancel the children
  # that have not yet replied once the expected count is reached.
  # With `remaining:` one can tell the concurrence to simply forget them,
  # they will go on and their, future, reply will be discarded (the concurrence
  # being already gone).
  #
  # `remaining:` may be shortened to `rem:`.
  #
  # ```
  # concurrence expect: 1 rem: 'forget'
  #     #
  #     # will forget child 'alpha' as soon as child 'bravo' replies,
  #     # and vice versa.
  #     #
  #   task 'alpha'
  #   task 'bravo'
  # ```
  #
  # ```
  # concurrence expect: 1 rem: 'wait'
  #     #
  #     # if 'alpha' replies before 'bravo', the concurrence will wait for
  #     # 'bravo', without cancelling it. And vice versa.
  #     #
  #   task 'alpha'
  #   task 'bravo'
  # ```
  #
  # ## on_receive: / receiver:
  #
  # Sets a function that is to be run each time a concurrence branch replies.
  # Should return a boolean, `true` for the concurrence to end (and trigger
  # the merging) or `false` for the concurrence to go on (and replies from
  # other branches to be received).
  #
  # In this example, the receiver is actually an implementation of the default
  # receive behaviour, "concurrence" merges as soon as all the children have
  # replied (`>= (length replies) branch_count`).
  # ```
  # define r reply, from, replies, branch_count
  #   >= (length replies) branch_count
  # concurrence on_receive: r
  #   + 1 2
  #   + 3 4
  # ```
  #
  # The receiver can be used to change the reply payload. Instead of
  # returning a boolean, it can return an object with the `done:` and
  # the `payload:` keys:
  # ```
  # define r reply, from, replies, branch_count, over
  #   set reply.ret (+ reply.ret 10)
  #   { done: (>= (length replies) branch_count), payload: reply }
  # concurrence on_receive: r
  #   + 1 2
  #   + 3 4
  # ```
  # The first branch thus returns `1 + 2 + 10`, while the second one returns
  # `3 + 4 + 10`.
  #
  # The signature for receiver functions is:
  # `define r reply, from, replies, branch_count`
  #
  # * _reply_ the current reply, here something like `{ ret: 3 }`.
  # * _from_ a string like "0_1_1", the nid of the node that emitted
  #   the current reply.
  # * _replies_ an object indexing the replies received so far, like
  #   `{ "0_1_1" => { "ret" => 13 } }`.
  # * _branch_count_ simply contains the count of branches. It should be
  #   superior or equal to the size of _rets_ and _replies_.
  # * _over_ is set to `true` if a previous receiver call said the
  #   concurrence should end. It is set to `false` else. So it's `true`
  #   for replies post-merge. It might happen for children answering
  #   right after the merge limit and children of concurrences that
  #   wait for all the replies, see the `remaining:` attribute above.
  #
  # ## on_receive (non-attribute)
  #
  # Sometimes, it's better to declutter the concurrence and write the
  # on_receive as a 'special' child rather than a attribute:
  #
  # ```
  # define r reply, from, replies, branch_count
  #   >= (length replies) branch_count
  # concurrence on_receive: r
  #   + 1 2
  #   + 3 4
  # ```
  # becomes
  # ```
  # concurrence tag: 'x'
  #   on_receive (def \ >= (length replies) branch_count)
  #   + 12 34
  #   + 56 78
  # ```
  # One can even express the function has a 'block':
  # ```
  # concurrence tag: 'x'
  #   on_receive
  #     >= (length replies) branch_count
  #   + 12 34
  #   + 56 78
  # ```
  #
  # ## on_merge: / merger: / merge:
  #
  # the function given to `on_merge:` or `merger:` is called once the
  # concurrence has gathered enough replies (or the right replies,
  # depending on `on_receive:` / `receiver:` or `expect:`).
  #
  # In the example below, the merging function take all the `f.ret` and
  # selects the maximum one:
  # ```
  # define m rets, replies, branch_count
  #   rets | values _ | max _
  # concurrence on_merge: m
  #   + 3 4 5
  #   + 6 7 8
  #   + 1 2 3
  # ```
  # It can be shortened to:
  # ```
  # concurrence on_merge: (def rets \ rets | values _ | max _)
  #   + 3 4 5
  #   + 6 7 8
  #   + 1 2 3
  # ```
  # `rets` looks like `{ "0_1_1" => 12, "0_1_2" => 21, "0_1_3" => 6 }`,
  # hence the `rets | values _ | max _`.
  #
  # The signature for the merge function looks like:
  # `define m rets, replies, branch_count`
  #
  # * _rets_ is the object collecting the `f.ret` of the replies to merge,
  #   like `{ "0_1_1" => 12, "0_1_2" => 21, "0_1_3" => 6 }` as seen above.
  # * _replies_ is the equivalent but for the whole reply payload (fields),
  #   like `{"0_1"=>{"ret"=>12}, "0_2"=>{"ret"=>21}, "0_3"=>{"ret"=>6}}`.
  # * _branch_count_ simply contains the count of branches. It should be
  #   superior or equal to the size of _rets_ and _replies_.
  #
  # ### merge: and string values
  #
  # By default, the merge technique is a deep merge favouring the first
  # branches to reply. By passing a string value to merge:/merger:/on_merge:
  # one can select a different merge technique.
  #
  # * "first" (the default) - the first branch to reply has priority in the deep  #   merge
  # * "last" - the last branch to reply has priority in the deep merge
  # * "top" or "north" - the branch are prioritized in the order they are
  #   in the flow definition
  # * "bottom" or "south" - the branch are prioritized in the reverse order of
  #   the flow definition
  #
  # Adding "plain" (for example "south plain") tells the "concurrence" not to
  # use a deep merge but the plain/vanilla merge found in Ruby.
  #
  # "north plain" can be abbreviated to "np", "bottom" to "b", "first plain" to
  # "fp", etc...
  #
  # ## on_merge (non-attribute)
  #
  # Like `receiver:` / `:on_receive` has the `on_receive` construct, there
  # is the `on_merge` construct which accepts a function or a block:
  # ```
  # concurrence
  #   on_merge (def rs \ rs | values _ | max _)
  #   + 1 4 5
  #   + 3 7 8
  #   + 6 2 3
  # ```
  # or
  # ```
  # concurrence
  #   on_merge
  #     rets | values _ | min _
  #   + 3 4 5
  #   + 6 7 8
  #   + 1 2 3
  # ```
  #
  # ## child_on_error: / children_on_error:
  #
  # Setting the common attribute `on_error:` on a concurrence is OK, but it
  # only catches a single error and then the flow resumes after the concurrence:
  # ```
  # sequence
  #   set l []
  #   concurrence on_error:
  #       (def msg err \ push l "error at $(msg.nid): $(err.msg)")
  #     push l 0
  #     push l x  # fails because 'x' is unknown)
  #   push l 2
  # ```
  # The `push l x` here fails, the on_error is triggered and the flow resumes
  # at `push l 2`. `l` ends up containing
  # `[ 0, "error at 0_1_2_1: cannot find \"x\"", 2 ]`.
  #
  # It is easy to set an `on_error:` on each child:
  # ```
  # sequence
  #   set l []
  #   define oe msg err
  #     push l "error at $(msg.nid): $(err.msg)"
  #   concurrence
  #     push l 0 on_error: oe
  #     push l x on_error: oe
  #   push l 2
  # ```
  # But that can also be written as:
  # ```
  # sequence
  #   set l []
  #   concurrence child_on_error:
  #       (def msg err \ push l "error at $(msg.nid): $(err.msg)")
  #     push l 0
  #     push l x
  #   push l 2
  # ```
  # `child_on_error` can also be written as `children_on_error`.
  #
  # The signature for the error handler is:
  # * _msg_ the message (usually `point: 'failed'`) communicating the error
  # * _err_ contains the error itself, it's a shortcut to `msg.error`
  #
  #
  # ## child_on_error / children_on_error (non-attribute)
  #
  # Those who prefer to tie handlers via a node rather than an attribute
  # can do so:
  # ```
  # sequence
  #   set l []
  #   concurrence
  #     child_on_error (def msg err \ push l "error at $(msg.nid): $(err.msg)")
  #     push l 0
  #     push l x
  #   push l 2
  # ```
  # One step further, with a block:
  # ```
  # sequence
  #   set l []
  #   concurrence
  #     child_on_error
  #       push l "error at $(msg.nid): $(err.msg)")
  #     push l 0
  #     push l x
  #   push l 2
  # ```

  include Flor::Pro::ReceiveAndMerge

  name 'concurrence'

  def pre_execute

    @node['atts'] = []

    pre_execute_rewrite
  end

  def receive_last_att

    return wrap_reply unless children[@ncid]

    branches = (@ncid..children.size - 1).to_a
    @node['branch_count'] = branches.count

    branches
      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children
  end

  def receive_non_att

    if message['from_on']
      super
      #receive_from_on
    elsif Flor.same_sub?(nid, from)
      receive_from_branch
    elsif from_error_handler?
      wrap_reply
    elsif @node['on_receive_nids'] && @node['on_receive_nids'][0] == from
      receive_from_receiver
    else
      receive_from_merger
    end
  end

  def add

    super

    i = Flor.child_id(message['tnid'])
    ts = message['trees']

    @node['branch_count'] += ts.size

    ts
      .collect.with_index { |t, j|
        pl = Flor.dup(message['payload'] || node_payload.copy)
        execute_child(i + j, 0, 'payload' => pl) }
      .flatten(1)
  end

  protected

  alias branch_count non_att_count
    # used by ReceiveAndMerge to determine procedure end

  def receive_from_child_when_closed

    ms = receive

    return [] if ms.empty?

    pop_on_receive_last || ms
  end

  def make_on_def(cn, l)

    c0 = cn.length == 1 ? cn[0] : nil

    return c0 if Flor.is_definition_tree?(c0)
    return make_on_def(c0[1], l) if Flor.is_att_tree?(c0)

    [ 'def', cn, l ]
  end

  def rewrite_as_attribute(child_tree)

    ct0, ct1, ct2 = child_tree

    k = [ ct0, [], ct2 ]
    v = make_on_def(ct1, ct2)

    [ '_att', [ k, v ], ct2 ]
  end

  REWRITE_AS_ATTS = %w[
    on_receive on_merge
    child_on_error children_on_error
      ].freeze
        #
        # heads of the child nodes that should get rewritten as attributes
        # of the concurrence ...

  def pre_execute_rewrite

    t = tree
    t1 = t[1]

    return if t1.empty?

    atts, cldn =
      t1.inject([ [], [] ]) { |r, ct|
        if ct[0] == '_att'
          r[0] << ct
        elsif REWRITE_AS_ATTS.include?(ct[0])
          r[0] << rewrite_as_attribute(ct)
        else
          r[1] << ct
        end
        r }

    nt1 = atts + cldn

    @node['tree'] = [ t[0], nt1, *t[2..-1] ] \
      if nt1 != t1
  end
end

