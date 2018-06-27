
class Flor::Pro::Index < Flor::Procedure

  # TODO * (star) should follow dense / JSONPath, go deep!
  # TODO .. (dotdot) (see dense)

  name '_index'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    @node['indexes'] ||= receive_payload_ret

    super
  end

  def receive_last

    @keys = []
    @values = []

    node_payload_ret
      .each { |coll| index(coll) }

    payload['ret'] = @values

    pn = parent_node
    path = pn && pn['path']
    path.concat(@keys.uniq) if path

    wrap
  end

  protected

  def index(coll)

    case [ coll.class, @node['indexes'].is_a?(Array) ]
    when [ Array, false ] then index_array(coll)
    when [ Array, true ] then slice_array(coll)
    when [ Hash, false ] then index_object(coll)
    when [ Hash, true ] then slice_object(coll)
    else fail TypeError.new("cannot index #{coll.class}")
    end
  end

  def index_array(arr)

    index = @node['indexes']

    fail TypeError.new("cannot index array with key #{index.inspect}") \
      unless index.is_a?(Integer)

    @keys << index
    @values << arr[index]
  end

  def slice_array(arr)

    @keys << @node['indexes']

    @node['indexes']
      .each { |index| do_slice_array(arr, index) }
  end

  def do_slice_array(arr, index)

    if index == '*'
      @values.concat(arr)
    elsif index.is_a?(Integer)
      @values << arr[index]
    elsif Flor.is_regex_tree?(index)
      fail TypeError.new(
        "cannot index array with regex #{Flor.to_regex(index).inspect}")
    elsif index.is_a?(Array) && index.length == 2
      @values.concat(array_slice(arr, index[0], index[0] + index[1] - 1, 1))
    elsif index.is_a?(Array) && index.length == 3
      @values.concat(array_slice(arr, *index))
    else
      fail TypeError.new(
        "cannot index array with key #{index.inspect}")
    end
  end

  def array_slice(arr, be, en, st)

    l = arr.length
    be = l + be if be < 0
    en = l + en if en < 0

    #keys = []
    values = []
    i = be

    while i >= 0 && i < l && i != (en + st)
      #keys << i
      values << arr[i]
      i = i + st
    end

    values
  end

  def index_object(obj)

    index = @node['indexes']

    @keys << index
    @values << obj[index]
  end

  def slice_object(obj)

    indexes = @node['indexes']

    if indexes.include?('*')
      @keys << [ '*' ]
      @values.concat(obj.values)
    else
      @keys << []
      indexes.each { |index| do_slice_object(obj, index) }
    end
  end

  def do_slice_object(obj, index)

    if Flor.is_regex_tree?(index)
      r = Flor.to_regex(index)
      obj.each { |k, v|
        next unless k.match(r)
        @keys.last << k
        @values << obj[k] }
    else
      @keys.last << index
      @values << obj[index]
    end
  end
end

