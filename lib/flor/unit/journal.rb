
module Flor

  # A Journal hook, receives only "consumed" messages and
  # keeps a copy of all of them.
  #
  # Used in specs, do not uses as-is in production, since it simply
  # grows in memory...
  #
  class Journal

    attr_reader :messages

    def initialize(unit)

      # Add a #journal method to the flor unit so that
      # `unit.journal` yields the message list.
      #
      unit.singleton_class.instance_eval do

        define_method(:journal) do
          @hooker['journal'].messages
        end
      end

      @messages = []
    end

    # Tells the hooker that this hook is only interested in message that
    # have been "consumed", remember, the hooker passes messages to
    # hooks before consumption and after consumption. In this case only
    # consumed messages are passed.
    #
    # Other hooks may declare they are only interested in messages
    # belonging to a certain domain or having a certain tag.
    # See spec/unit/unit_hooks_spec.rb for more filtering examples.
    #
    def opts; { consumed: true }; end

    # The method used by the hooker to give consumed messages to this journal
    #
    def notify(executor, message)

      @messages << Flor.dup(message)
        # stores a deep clone of each consumed message

      [] # no new messages
    end
  end
end

