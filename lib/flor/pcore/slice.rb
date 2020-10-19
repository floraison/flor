# frozen_string_literal: true

class Flor::Pro::Slice < Flor::Procedure
  #
  # Takes an array or a string and returns a slice of it (a new
  # array or a new string).
  #
  # "index" takes an array or a string and returns the element (character)
  # at the given index.
  #
  # ## slice
  #
  # ```
  # set a [ 'alpha' 'bravo' 'charly' ]
  #
  # slice a 1 -1            # sets [ 'bravo', 'charly' ] into the field 'ret'
  # slice a from: 1 to: -1  # same as above
  #
  # a
  # slice 1 -1  # sets [ 'bravo', 'charly' ] into the field 'ret'
  # slice 1 -1  # sets [ 'charly' ] into the field 'ret'
  # ```
  #
  # It slices the content of `f.ret` by default:
  # ```
  # set a [ 0 1 2 3 ]
  # # ...
  # a                  # (copy content of a into f.ret)
  # slice 1 count: 2   # sets [ 1, 2 ] into the field 'ret'
  # ```
  #
  # ## index
  #
  # ```
  # set a [ 'alpha' 'bravo' 'charly' ]
  #
  # index a (-2)    # sets 'bravo' into the field 'ret'
  # index a at: -2  # sets 'bravo' into the field 'ret'
  # ```
  #
  # It indexes the content of `f.ret` by default:
  # ```
  # set a [ 0 1 2 3 4 ]
  # # ...
  # a                    # (copy content of a into f.ret)
  # index (-2)           # sets 3 into the field 'ret'
  # ```
  #
  # ## see also
  #
  # length

  names 'slice', 'index'

  # three cases: [ start, count ], [ start, end ], and [ start, end, step ]

  def pre_execute

    unatt_unkeyed_children

    @node['atts'] = []
    @node['rets'] = []
  end

  def receive_last

    send(heap)
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

