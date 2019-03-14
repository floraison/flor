
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

  def compute_param_key(t)

    t0 = t[0]
    k = t0[0]

    if k == '_ref' && t0[1].is_a?(Array) && t0[1].length > 0
      t[0][1].collect { |tt| tt[1].to_s }.join('.')
    else
      k
    end
  end

  def map_arguments_to_parameters

    @node['vars'] = {}

    args = message['arguments']

    @node['vars']['arguments'] = args

    tr = tree
    retree = nil

    params = tr[1]
      .select { |t| t[0] == '_att' }
      .inject([]) { |a, t|
        t1 = t[1]
        a << [ compute_param_key(t1), t[1][0], t[1][1] ]
        a }
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

    params.each do |param_key, param_tree|
      next if param_tree[0] == '_ref'
      arg_i = args.index { |arg_key, arg_val| arg_key == param_key }
      next unless arg_i
      arg_key, arg_val = args.delete_at(arg_i)
      seen << arg_key
      set_param(param_key, arg_val)
    end
#puts "== 0 vars:"; pp @node['vars']
    params.each_with_index do |(param_key, param_tree, param_val), param_i|
      ref = param_tree[0] == '_ref'
      next if ! ref && @node['vars'].has_key?(param_key)
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
#puts "\n== 1 fields: "; pp payload.current
  #
#print "vars: "
#pp @node['vars'].collect { |k, v| [ k, JSON.dump(v)[0, 20] + "..." ] }
#print "vars: "
#@node['vars'].each { |k, v| print "#{k.inspect} --> "; pp v }

#puts "== retree:"; pp retree; puts
    @node['tree'] = retree if retree
  end

  def set_param(key, val)

# TODO root variables...
    return unless key

    if m = key.match(/\A(?:field|fld|f)\.(.+)\z/)
      Dense.set(payload.copy, m[1], val)
    elsif m = key.match(/\A(?:variable|var|v)\.(.+)\z/)
      Dense.set(@node['vars'], m[1], val)
    else
      #@node['vars'][key] = val
      Dense.set(@node['vars'], key, val)
    end
  end
end

