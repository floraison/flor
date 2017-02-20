
module Flor

  class Journal

    attr_reader :messages

    def initialize(unit)

      unit.singleton_class.instance_eval do
        define_method(:journal) do
          @hooker['journal'].messages
        end
      end

      @messages = []
    end

    def opts; { consumed: true }; end

    def notify(executor, message)

      @messages << Flor.dup(message)

      [] # no new messages
    end
  end
end

