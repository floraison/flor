
class Flor::Pro::Define < Flor::Procedure
  #
  # Defines a function.
  #
  # In its `define` flavour, will take a function body and assign it to
  # variable.
  # ```
  # define sum a, b # make variable 'sum' hold the function
  #   +
  #     a
  #     b
  #   # yields the function, like `fun` and `def` do
  #
  # sum 1 2
  #   # will yield 3
  # ```
  #
  # In the `fun` and `def` flavours, the function is unnamed, it's thus not
  # bound in a local variable.
  # ```
  # map [ 1, 2, 3 ]
  #   def x
  #     + x 3
  # # yields [ 4, 5, 6 ]
  # ```
  #
  # It's OK to generate the function name at the last moment:
  # ```
  # sequence
  #   set prefix "my"
  #   define "$(prefix)-sum" a b
  #     + a b
  # ```
  #
  # ## see also
  #
  # apply.

  names %w[ def fun define ]

  def execute

    if i = att_children.index { |c| %w[ _dqs _sqs ].include?(c[1].first.first) }
      execute_child(i)
    else
      receive_att
    end
  end

  def receive_att

    t, sig = flatten_tree

    bad_param =
      sig.inject(nil) { |r, a|
        a10 = a[1][0]
        pa = a10[0] == '_ref' && a10[1].size > 1 && a10[1].collect { |e| e[1] }
        break pa.join('.') if pa && ! pa[0].match(/\A(f|fld|field)\z/)
        nil }

    fail Flor::FlorError.new(
      "cannot accept #{bad_param.inspect} as parameter", self
    ) if bad_param

    cnode = lookup_var_node(@node, 'l')
    cnid = cnode['nid']
    fun = counter_next('funs') - 1

    (cnode['closures'] ||= []) << fun

    val = [
      '_func',
      { 'nid' => nid, 'tree' => t, 'cnid' => cnid, 'fun' => fun },
      t[2] ]

    if heap == 'define'
      name =
        if @message['point'] == 'execute'
          t[1].first[1].first[0]
        else
          payload['ret']
        end
      set_var('', name, val)
    end

    wrap('ret' => val)
  end

  protected

  def flatten_tree

#puts "== tree"
#pp tree
    tre = tree
    off = heap == 'define' ? 1 : 0
    sig = tre[1][off..-1].select { |t| t[0] == '_att' }
#puts "sig: " + sig.inspect
#p sig[0][0]
#p sig[0][1][0]

    return [ tre, sig ] unless wrapped?(sig)

    # There is a parenthese around the parameters, let's unwrap that...

    hed = Flor.dup(tre[1][0, off])
    sig = Flor.dup(sig)
    bdy = Flor.dup(tre[1][(off + sig.length)..-1])

    att0 = sig[0][1][0]
    att0atts = att0[1]
    att0[1] = []

    sig = sig + att0atts

    [ [ heap, hed + sig + bdy, *tre[2..-1] ],
      sig ]
  end

  def wrapped?(sig)

    return false if sig.length != 1
    return false if sig[0][1][0][0] == '_ref'
    sig[0][1][1] != []
  end
end

