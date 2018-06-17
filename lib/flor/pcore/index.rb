
class Flor::Pro::Index < Flor::Procedure

  name 'index'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    @node['index'] ||= receive_payload_ret

    super
  end

  def receive_last

    inds = @node['index']

    r =
      if inds.is_a?(Array)
        slice(node_payload_ret, inds)
      else
        index(node_payload_ret, inds)
      end

    wrap_reply('ret' => r)
  end

  protected

  # TODO regexes

  def slice (coll, inds)

    if coll.is_a?(Array)
      slice_array(coll, inds)
    else
      slice_object(coll, inds)
    end
  end

  def index(coll, ind)

    if coll.is_a?(Array)
      index_array(coll, ind)
    else
      index_object(coll, ind)
    end
  end

  def index_array(a, ind)

    fail TypeError.new("cannot index array with key #{ind.inspect}") \
      unless ind.is_a?(Integer)

    a[ind]
  end

  def index_object(o, ind)

#p o
#p ind
    o[ind]
  end

  def slice_array(a, inds)

#p a
#p inds
    return a if inds.include?('*')

    inds
      .inject([]) { |r, ind|
        if Flor.is_regex_tree?(ind)
          fail TypeError.new("cannot index array with regex #{ind[1]}")
        elsif ind.is_a?(Array)
          r.concat(slice_array_(a, ind))
        else
          r.push(index_array(a, ind))
        end }
  end

  def slice_object(o, inds)

#p o
#p inds
    return o.values if inds.include?('*')

    inds
      .inject([]) { |a, ind|
        if Flor.is_regex_tree?(ind)
          r = Flor.to_regex(ind)
          a.concat(
            o.keys.inject([]) { |aa, k| aa.push(o[k]) if r.match(k); aa })
        else
          a.push(
            o[ind])
        end }
  end
end

