
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
# # # # #
#
#  def key_split(key) # => category, mode, key
#
#    m = key.match(
#      /\A(?:([lgd]?)((?:v|var|variable)|w|f|fld|field|t|tag)\.)?(.+)\z/)
#            ^mode   ^cat                                        ^key
#    ca = (m[2] || 'v')[0, 1]
#    mo = m[1] || ''
#    ke = m[3]
#
#    [ ca, mo, ke ]
#  end

  def lookup(path)

    # TODO adapt path to Dense
    #      or should that be done in the lookup_ methods themselves?

    case path.first
    when /\Af(?:ld|ield)?\z/
      lookup_field(nil, path[1..-1]) # mod -> nil...
    when /\A([lgd]?)v(?:ar|ariable)?\z/
      lookup_var(@node, $1, path[1], path[2..-1])
    when /\At(?:ag)\z/
      lookup_tag(nil, path[1..-1])
    else
# variable?
fail NotImplementedError
    end
  end
    #
    # for now, let's have a #lookup here
    # later on, let's merge with the one in the Node parent class
end

