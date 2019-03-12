
class Flor::Pro::UnderscoreApply < Flor::Procedure

  name '_apply'

  def execute

    #if oe = message['on_error']
    #  @node['in_on_error'] = oe
    #end
      #
      # which is equivalent, for now, to
      #
    if message['on_error']
      #@node['in_on_error'] = true
      @node['in_on_error'] = from
    end

    vars = @node['vars'] = {}
    args = message['arguments']

    vars['arguments'] = args

    tr = tree
    retree = nil

    atts = tr[1].inject([]) { |a, t| a << t[1] if t[0] == '_att'; a }
    args = args.dup
#puts "\n---"
#puts "== atts (sig):"
#atts.each_with_index { |a, i| printf "%2d: %s\n", i, a.inspect }
#puts "== args:"
#args.each_with_index { |a, i| printf "%2d: %s\n", i, a.inspect }
#puts

    # first, make 2 passes on atts
    # 1). grab named args
    # 2). grab remaining args
    # then make 1 pass on still remaining args
    # 1). set vars if not yet set

    seen = []

    atts.each do |(att_key, _), _|
      arg_i = args.index { |arg_key, arg_val| arg_key == att_key }
      next unless arg_i
      arg_key, arg_val = args.delete_at(arg_i)
      seen << arg_key
      vars[att_key] = arg_val
    end
#puts "== 0 vars:"; pp vars
    atts.each_with_index do |((att_key, _), att_val), att_i|
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
      end
    end
#puts "== seen:"; p seen
    args.each do |arg_key, arg_val|
      vars[arg_key] = arg_val unless seen.include?(arg_key)
    end

#puts "\n== 1 vars: "; pp vars
#print "vars: "; pp vars.collect { |k, v| [ k, JSON.dump(v)[0, 20] + "..." ] }
#print "vars: "; vars.each { |k, v| print "#{k.inspect} --> "; pp v }

    @node['tree'] = retree if retree
#puts "== retree:"; pp retree; puts

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

  def wrap_reply(h={})

    ms = super

    ioe = @node['in_on_error']
    ms[0]['from_on_error'] = ioe if ioe

    ms
  end
end

