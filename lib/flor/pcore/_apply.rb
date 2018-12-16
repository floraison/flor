
class Flor::Pro::UnderscoreApply < Flor::Procedure

  name '_apply'

  def execute

    vars = @node['vars'] = {}
    args = message['arguments']

    vars['arguments'] = args

    #vars['args'] = args.collect(&:last)
      # FIXME values get stored twice... use some kind of pseudo-variable

    tr = tree
    retree = nil

    atts = tr[1].inject([]) { |a, t| a << t[1] if t[0] == '_att'; a }
    args = args.dup
#puts "\n---"
#puts "== atts (sig):"; pp atts;   # signature
#puts "== args (given):"; pp args  # passed arguments
#puts

    # make 2 passes
    # 1). grab named args
    # 2). grab unamed args (arg_key == nil)

    seen = []

    atts
      .each { |(att_key, _), _|
        arg_i = args.index { |arg_key, arg_val| arg_key == att_key }
        next unless arg_i
        arg_key, arg_val = args.delete_at(arg_i)
        seen << arg_key
        vars[att_key] = arg_val }
#puts "== 0 vars:"; pp vars
    atts
      .each_with_index { |((att_key, _), att_val), att_i|
        next if vars.has_key?(att_key)
        seen << att_key
        if att_i < args.length
          arg_key, arg_val = args[att_i]
          seen << arg_key
          vars[att_key] = arg_val
        elsif att_val
          l = tree[2]
          retree ||= Flor.dup(tr)
          retree[1][att_i] = [ 'set', [ [ att_key, [], l ], att_val ], l ]
        else
          vars[att_key] = nil
        end }
#puts "== seen:"; p seen
    args
      .each { |arg_key, arg_val|
        vars[arg_key] = arg_val unless seen.include?(arg_key) }

#puts "\n== 1 vars: "; pp vars
#print "vars: "; pp vars.collect { |k, v| [ k, JSON.dump(v)[0, 20] + "..." ] }
#print "vars: "; vars.each { |k, v| print "#{k.inspect} --> "; pp v }

    @node['tree'] = retree if retree
#puts "== retree:"; pp retree

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

