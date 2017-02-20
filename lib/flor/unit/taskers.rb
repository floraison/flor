
module Flor

  class BasicTasker

    attr_reader :ganger, :conf, :message

    def initialize(ganger, conf, message)

      @ganger = ganger
      @conf = conf
      @message = message
    end

    protected

    def reply(force=false)

      @ganger.reply(@message) if force || @ganger
    end

    def exid; @message['exid']; end
    def nid; @message['nid']; end

    def execution

      @ganger.unit.execution(exid)
    end

    # For domain taskers
    #
    def route(name)

      if name == false

        [
          Flor.dup_and_merge(
            @message,
            'routed' => false)
        ]

      else

        [
          Flor.dup_and_merge(
            @message,
            'tasker' => name, 'original_tasker' => @message['tasker'],
            'routed' => true)
        ]
      end
    end
  end
end

