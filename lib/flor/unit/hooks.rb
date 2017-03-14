
module Flor

  class BasicHook

    def initialize(executor, opts, message)

      @executor = executor
      @opts = opts
      @message = message
    end

    protected

    def point

      @message['point']
    end
  end

  class PointHook < BasicHook

    def on

      m = "on_#{point}"

      respond_to?(m) ? send(m) : on_default
    end

    protected

    def on_default

      []
    end
  end
end
