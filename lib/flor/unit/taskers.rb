# frozen_string_literal: true

module Flor

  class BasicTasker

    attr_reader :ganger, :conf, :message

    def initialize(ganger, conf, message)

      @ganger = ganger
      @conf = conf
      @message = message
    end

    protected

    def exid; @message['exid']; end
    def nid; @message['nid']; end

    def payload; @message['payload']; end
    alias fields payload

    def payload=(h)

      fail ArgumentError.new("payload must be a Hash, not a #{h.class}") \
        unless h.is_a?(Hash)

      @message['payload'] = h
    end
    alias fields= payload=

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

        [ Flor.dup_and_merge(
            @message,
            'tasker' => name, 'original_tasker' => @message['tasker'],
            'routed' => true) ]

      else

        [ Flor.dup_and_merge(
            @message,
            'routed' => !! name) ]
      end
    end

    def reply(message=@message, force=false)

      fail ArgumentError.new(
        "argument to reply must be a Hash but is #{message.class}"
      ) unless message.is_a?(Hash)

      @ganger.return(derive_message(message)) if force || @ganger

      [] # very important, return no further messages
    end

    def reply_with_error(error)

      reply(
        Flor.to_error_message(@message, error))
    end

    # So that #reply may be called with
    # ```
    # reply
    # reply(@message)
    # reply(payload: {})
    # reply(ret: 123)
    # reply(ret: 123, set: { a: 1 }, unset: [ :b ])
    # ```
    #
    def derive_message(m)

      exid = m['exid']
      nid = m['nid']
      pl = m['payload']

      return m if Flor.is_exid?(exid) && Flor.is_nid?(nid) && pl.is_a?(Hash)

      m = Flor.to_string_keyed_hash(m)
      h = Flor.dup_message(@message)
      ks = m.keys

      if ks == [ 'payload' ]

        h['payload'] = m['payload']

      elsif (ks & %w[ ret set unset ]).size > 0

        pl = (h['payload'] ||= {})

        pl['ret'] = m['ret'] if m.has_key?('ret')
        (m['set'] || {}).each { |k, v| pl[k] = v }
        (m['unset'] || []).each { |k| pl.delete(k.to_s) }

      else

        h['payload'] = m
      end

      h
    end
  end

  # A BasicTasker with stages (pre / on / post)
  #
  class StagedBasicTasker < BasicTasker

    def call_task

      call_one_of(:pre_task)
      call_one_of(:on_task, :task)
    end

    def call_detask

      call_one_of(:pre_detask, :pre_cancel)
      call_one_of(:on_detask, :on_cancel, :detask, :cancel)
    end

    protected

    def call_one_of(*ms)

      m = ms.flatten.find { |mm| respond_to?(mm) }

      send(m) if m
    end

    def reply(message=@message, force=false)

      fail ArgumentError.new(
        "argument to reply must be a Hash but is #{message.class}"
      ) unless message.is_a?(Hash)

      pt = @message['point']

      ms = [ "post_#{pt}" ]; ms << :post_cancel if pt == 'detask'
        #
      call_one_of(ms)

      msg = derive_message(message)

      @ganger.return(msg) if force || @ganger

      [] # very important, return no further messages
    end
  end
end

