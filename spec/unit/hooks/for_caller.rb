
# for spec/unit/caller_spec.rb

module Romeo

  class Callee

    def on(message)

      [ { 'point' => 'receive', 'mm' => 2 } ]
    end
  end

  class Failer

    def on(message)

      fail "pure fail at m:#{message['m']}"
    end
  end
end

