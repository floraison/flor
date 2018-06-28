
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

#  def lookup(name, silence_index_error=false)
#
#    cat, mod, key_and_path = key_split(name)
#    key, pth = key_and_path.split('.', 2)
#
#    if [ cat, mod, key ] == [ 'v', '', 'node' ]
#      lookup_in_node(pth)
#    elsif cat == 'v'
#      lookup_var(@node, mod, key, pth)
#    elsif cat == 't'
#      lookup_tag(mod, key)
#    else
#      lookup_field(mod, key_and_path)
#    end
#
#  rescue KeyError, TypeError
#
#    raise unless silence_index_error
#    nil
#  end
#
#    m = key.match(
#      /\A(?:([lgd]?)((?:v|var|variable)|w|f|fld|field|t|tag)\.)?(.+)\z/)

  def lookup(path)

    case path.first
    when /\Af(?:ld|ield)?\z/ then lookup_field(nil, path[1..-1]) # mod -> nil...
    when /\A([lgd]?)v(?:ar|ariable)?\z/ then 1
    when /\At(?:ag)\z/ then 2
    else 9
    end
  end
    #
    # for now, let's have a #lookup here
    # later on, let's merge with the one in the Node parent class
end

