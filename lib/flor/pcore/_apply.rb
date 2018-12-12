
class Flor::Pro::UnderscoreApply < Flor::Procedure

  name '_apply'

  def execute

    args = @node['vars']['arguments']

    tr = tree
    rewrites = {}

    tr[1]
      .select { |t| t[0] == '_att' }
      .collect { |t| t[1] }
      .each_with_index { |a, i|
        if i < args.length
          @node['vars'][a[0][0]] = args[i]
        elsif a.length > 1
          rewrites[i] = [ 'set', a, tree[2] ]
        else
          @node['vars'][a[0][0]] = nil
        end }

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

