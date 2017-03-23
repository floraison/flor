
class Flor::Pro::Matchr < Flor::Procedure
  #
  # Matches a string against a regular expression.
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
  #
  # When there is a single argument, `matchr` and `match?` will try
  # to take the string out of `$(f.ret)`.
  # ```
  # "blue moon"
  # match? (/blue/)
  #   # => true
  #
  # "blue moon"
  # match? 'blue'
  #   # => true
  #
  # /blue/
  # match? 'blue moon'
  #   # => true
  #
  # 'blue'
  # match? (/black/)
  #   # => false
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

    rets = @node['rets'].dup
    rets.unshift(node_payload_ret) if rets.size < 2

    fail ArgumentError.new(
      "'#{tree[0]}' needs 1 or 2 arguments"
    ) if rets.size < 2

    rex =
      rets.find { |r| r.is_a?(Array) && r[0] == '_rxs' } ||
      rets.last

    str = (rets - [ rex ]).first

    rex = rex.is_a?(String) ? rex : rex[1].to_s
    rex = rex.match(/\A\/[^\/]*\/[a-z]*\z/) ? Kernel.eval(rex) : Regexp.new(rex)

    [ rex, str ]
  end
end

