
class Flor::Pro::UnderscoreApply < Flor::Procedure

  name '_apply'

  def execute

    vars = @node['vars'] = {}
    args = message['arguments']

    vars['arguments'] = args.dup
      # since args itself gets dissected below

    #vars['args'] = args.collect(&:last)
      # FIXME values get stored twice... use some kind of pseudo-variable

    tr = tree
    rewrites = {}

    atts = tr[1].inject([]) { |a, t| a << t[1] if t[0] == '_att'; a }
#puts "---"
#puts "== args:"; pp args
#puts "== atts:"; pp atts

    atts
      .each_with_index { |((att_key, _), att_val), att_i|

        arg_i = args.index { |arg_key, arg_val| arg_key == att_key } || 0
        #_, arg_val = args.delete_at(arg_i)
        arg = args.delete_at(arg_i)
        arg_val = arg && arg[1]
#p({
#  att_key: att_key, att_val: att_val, att_i: att_i,
#  arg_i: arg_i, arg: arg, arg_val: arg_val })

        if arg
          vars[att_key] = arg_val
        elsif att_val
          t2 = tree[2]
          rewrites[att_i] = [ 'set', [ [ att_key, [], t2 ], att_val ], t2 ]
        end }
#puts "== remaining args:"; p args

    args
      .each { |ak, av|
        vars[ak] = av if ak && ! vars.has_key?(ak) }
#puts "== vars: "; pp vars
#print "vars: "; pp vars.collect { |k, v| [ k, JSON.dump(v)[0, 20] + "..." ] }
#print "vars: "; vars.each { |k, v| print "#{k.inspect} --> "; pp v }

    if rewrites.any?
#puts "== rewrites: "; p rewrites
      rewrites.each { |i, t| tr[1][i] = t }
      @node['tree'] = tr
    end

    super
  end

  def execute_child(index=0, sub=nil, h=nil)

    t0 = tree[1][index] && tree[1][index][0]

    if t0 && %w[ _att _name ].include?(t0) # skip those
      execute_child(index + 1)
    else
      super
    end
  end

  #def cancel_when_closed
  #  return cancel if node_status_flavour == 'on-error'
  #  []
  #end
    #
    # as it was when "_apply" was an alias to "sequence"
end

