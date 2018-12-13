
class Flor::Pro::UnderscoreApply < Flor::Procedure

  name '_apply'

  def execute

    vars = @node['vars'] = {}
    args = message['arguments']

    vars['arguments'] = args

    #vars['args'] = args.collect(&:last)
      #
      # FIXME values get stored twice... use some kind of pseudo-variable

    tr = tree
    rewrites = {}

    atts = tr[1].inject([]) { |a, t| a << t[1] if t[0] == '_att'; a }
#puts "---"
#puts "args:"
#pp args
#puts "atts:"
#pp atts

    index = 0
    atts.each_with_index { |(att_key, att_val), att_i|
#puts "--- #{index} ---"; p att
      key = att_key[0]
      if arg = args[index]
        vars[key] = arg.last
      elsif att_val
        rewrites[att_i] = [ 'set', [ att_key, att_val ], tree[2] ]
      else
        vars[key] = nil
      end
      index += 1 }

    args.each { |ak, av| vars[ak] = av unless vars.has_key?(ak) }
#print "vars: "; pp vars

    if rewrites.any?
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

