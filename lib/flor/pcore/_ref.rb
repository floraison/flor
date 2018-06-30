
class Flor::Pro::Ref < Flor::Procedure

  names %w[ _ref _rep ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    payload['ret'] =
      if tree[0] == '_rep'
        @node['rets']
      else
        lookup(@node['rets'])
      end

    super
  end

  protected

  def lookup(path)

    # TODO adapt path to Dense
    #      or should that be done in the lookup_ methods themselves?

    case path.first
    when /\Af(?:ld|ield)?\z/
      lookup_field(nil, path[1..-1]) # mod -> nil...
    when /\At(?:ag)\z/
      lookup_tag(nil, path[1..-1])
    when /\A([lgd]?)v(?:ar|ariable)?\z/
      lookup_var(@node, $1, path[1], path[2..-1])
    else
      lookup_var(@node, '', path[0], path[1..-1])
    end
  end
    #
    # for now, let's have a #lookup here
    # later on, let's merge with the one in the Node parent class
end

