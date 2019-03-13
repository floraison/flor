
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

    map_arguments_to_parameters

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

  protected

  def map_arguments_to_parameters

    @node['vars'] = {}

    args = message['arguments']

    @node['vars']['arguments'] = args

    tr = tree
    retree = nil

    params = tr[1].inject([]) { |a, t| a << t[1] if t[0] == '_att'; a }
    args = args.dup
#puts "\n---"
#puts "== params:"
#params.each_with_index { |a, i| printf "%2d: %s\n", i, a.inspect }
#puts "== args:"
#args.each_with_index { |a, i| printf "%2d: %s\n", i, a.inspect }
#puts

    # first, make 2 passes on atts
    # 1). grab named args
    # 2). grab remaining args
    # then make 1 pass on still remaining args
    # 1). set vars if not yet set

    seen = []

    params.each do |(param_key, _), _|
      arg_i = args.index { |arg_key, arg_val| arg_key == param_key }
      next unless arg_i
      arg_key, arg_val = args.delete_at(arg_i)
      seen << arg_key
      set_param(param_key, arg_val)
    end
#puts "== 0 vars:"; pp @node['vars']
    params.each_with_index do |((param_key, _), param_val), param_i|
      next if @node['vars'].has_key?(param_key)
      seen << param_key
      if param_i < args.length
        arg_key, arg_val = args[param_i]
        seen << arg_key
        set_param(param_key, arg_val)
      elsif param_val
        l = tree[2]
        retree ||= Flor.dup(tr)
        retree[1][param_i] = [ 'set', [ [ param_key, [], l ], param_val ], l ]
      else
        set_param(param_key, nil)
      end
    end
#puts "== seen:"; p seen
    args.each do |arg_key, arg_val|
      set_param(arg_key, arg_val) unless seen.include?(arg_key)
    end

#puts "\n== 1 vars: "; pp @node['vars']
#print "vars: "
#pp @node['vars'].collect { |k, v| [ k, JSON.dump(v)[0, 20] + "..." ] }
#print "vars: "
#@node['vars'].each { |k, v| print "#{k.inspect} --> "; pp v }

#puts "== retree:"; pp retree; puts
    @node['tree'] = retree if retree
  end

  def set_param(key, val)

    @node['vars'][key] = val
  end
end

