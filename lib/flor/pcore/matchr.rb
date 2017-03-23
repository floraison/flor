
class Flor::Pro::Matchr < Flor::Procedure
  #
  # `matchr s r` will return an array of matching strings in `s` from regular
  # expression `r`.
  #
  # `match? s r` will return true if string `s` matches regular expression `r`.
  # It returns false else.
  #
  # ```
  # matchr "alpha", /bravo/
  #   # yields an empty array []
  #
  # match? "alpha", /bravo/  # => false
  # match? "alpha", /alp/    # => true
  # ```
  #
  # The second argument to `match?` and `matchr` is turned into a
  # regular expression.
  # ```
  # match? "alpha", 'alp'    # => true
  # ```

  names %w[ matchr match? ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    rex, str = arguments

    m = rex.match(str)

    payload['ret'] =
      if @node['heap'] == 'match?'
        !! m
      else
        m ? m.to_a : []
      end

    reply
  end

  protected

  def arguments

    fail ArgumentError.new(
      "'#{tree[0]}' needs at least 2 arguments"
    ) if @node['rets'].size < 2

    rex = @node['rets']
      .find { |r| r.is_a?(Array) && r[0] == '_rxs' } || @node['rets'].last

    str = (@node['rets'] - [ rex ]).first

    rex = rex.is_a?(String) ? rex : rex[1].to_s
    rex = rex.match(/\A\/[^\/]*\/[a-z]*\z/) ? Kernel.eval(rex) : Regexp.new(rex)

    [ rex, str ]
  end
end

