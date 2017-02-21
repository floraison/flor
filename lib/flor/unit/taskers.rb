
module Flor

  class BasicTasker

    attr_reader :ganger, :conf, :message

    def initialize(ganger, conf, message)

      @ganger = ganger
      @conf = conf
      @message = message
    end

    protected

    def return(force=false)

      @ganger.return(@message) if force || @ganger
    end
    alias reply return

    def exid; @message['exid']; end
    def nid; @message['nid']; end

    def payload; @message['payload']; end
    alias fields payload

    def attd; @message['attd']; end
    def attl; @message['attl']; end

    def tasker; @message['tasker']; end
    def taskname; @message['taskname']; end
    alias task_name taskname

    def vars; @message['vars']; end

    def execution

      @ganger.unit.execution(exid)
    end

    # For domain taskers
    #
    def route(name)

      if name.is_a?(String)

        [
          Flor.dup_and_merge(
            @message,
            'tasker' => name, 'original_tasker' => @message['tasker'],
            'routed' => true)
        ]

      else

        [
          Flor.dup_and_merge(
            @message,
            'routed' => !! name)
        ]
      end
    end
  end
end

