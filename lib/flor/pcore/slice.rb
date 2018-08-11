
class Flor::Pro::Slice < Flor::Procedure
  #
  # "slice" takes an array or a string and returns a slice of it (a new
  # array or a new string.
  #
  # "index" takes an array or a string and returns the element (character)
  # at the given index.
  #
  # ## slice
  #
  # TODO
  #
  # ## index
  #
  # TODO

  names 'slice', 'index'

  # three cases: [ start, count ], [ start, end ], and [ start, end, step ]

  def pre_execute

    unatt_unkeyed_children

    @node['atts'] = []
    @node['rets'] = []
  end

  def receive_last

    send(@node['heat0'])
  end

  protected

  def collection

    coll =
      @node['rets'].find { |e| e.respond_to?(:slice) } ||
      node_payload_ret

    fail Flor::FlorError.new(
      "cannot slice instance of #{coll.class}", self
    ) unless coll.respond_to?(:slice)

    coll
  end

  def slice

    coll = collection

    ints = @node['rets'].select { |e| e.is_a?(Integer) }

    st = att('from', 'start') || ints.shift || 0
    en = att('to', 'end') || ints.shift
    co = att('count')
    sp = att('step') || 1

    en ||= (st + co - 1)
    en = coll.length + en if en < 0

    ret =
      case coll
      when String
        do_slice(coll.chars, st, en, sp, true)
      when Array
        do_slice(coll, st, en, sp)
      else
        fail Flor::FlorError.new("cannot slice instance of #{coll.class}", self)
      end

    ret ||= ''

    wrap('ret' => ret)
  end

  def do_slice(coll, st, en, sp, join=false)

    l = coll.length

    return nil if st >= l

    r = []

    while st <= en && st < l
      r << coll[st]
      st = st + sp
    end

    join ? r.join : r
  end

  def index

    coll = collection
    index = att('at') || @node['rets'].find { |e| e.is_a?(Integer) }

    wrap('ret' => coll[index] || '')
  end
end

