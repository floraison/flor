
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
  # `pmatch s r` will return false it it doesn't match, it will return the
  # string matched else. If there is a capture group (parentheses) in the
  # pattern, it will return its content instead of the whole match.
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
  #
  # ```
  # # pmatch
  # pmatch 'string', /^str/                     # ==> 'str'
  # pmatch 'string', /^str(.+)$/                # ==> 'ing'
  # pmatch 'string', /^str(?:.+)$/              # ==> 'string'
  # pmatch 'strogonoff', /^str(?:.{0,3})(.*)$/  # ==> 'noff'
  # pmatch 'sutoringu', /^str/                  # ==> ''
  # ```

  names %w[ matchr match? pmatch ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    rex, str = arguments

    m = rex.match(str)

    payload['ret'] =
      case @node['heap']
      when 'match?' then !! m
      when 'pmatch' then (m && (m[1] || m[0])) || ''
      else m ? m.to_a : []
      end

    wrap_reply
  end

  protected

  def arguments

    rets = @node['rets'].dup
    rets.unshift(node_payload_ret) if rets.size < 2

    fail Flor::FlorError.new(
      "'#{tree[0]}' needs 1 or 2 arguments", self
    ) if rets.size < 2

    rex =
      rets.find { |r| Flor.is_regex_tree?(r) } ||
      rets.last

    str = (rets - [ rex ]).first

    rex = Flor.to_regex(rex)

    [ rex, str ]
  end
end

