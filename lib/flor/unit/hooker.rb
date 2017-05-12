
module Flor

  class Hooker

    # NB: logger configuration entries start with "hok_"

    def initialize(unit)

      @unit = unit

      @hooks = []
    end

    def shutdown

      @hooks.each do |n, o, hook, b|

        hook.shutdown if hook.respond_to?(:shutdown)
      end
    end

    def [](name)

      h = @hooks.find { |n, o, h, b| n == name }

      h ? h[2] || h[3] : nil
    end

    def wlist

      @wlist ||= self['wlist']
    end

    def add(*args, &block)

      name = nil
      hook = nil
      opts = {}

      args.each do |arg|
        case arg
          when String then name = arg
          when Hash then opts = arg
          else hook = arg
        end
      end

      hook = hook.new(@unit) if hook.is_a?(Class)

      @hooks << [ name, opts, hook, block ]
    end

    def notify(executor, message)

      (
        @hooks + executor.traps_and_hooks
      )
        .inject([]) do |a, (_, opts, hook, block)|
          # name of hook is piped into "_" oblivion

          a.concat(
            if ! match?(executor, hook, opts, message)
              []
            elsif hook.is_a?(Flor::Trap)
              executor.trigger_trap(hook, message)
            elsif hook
              executor.trigger_hook(hook, message)
            else
              executor.trigger_block(block, opts, message)
            end)
        end
    end

    protected

    def o(opts, *keys)

      array = false
      array = keys.pop if keys.last == []

      r = nil
      keys.each { |k| break r = opts[k] if opts.has_key?(k) }

      return nil if r == nil
      array ? Array(r) : r
    end

    def match?(executor, hook, opts, message)

      opts = hook.opts if hook.respond_to?(:opts) && opts.empty?

      c = o(opts, :consumed, :c)
      return false if c == true && ! message['consumed']
      return false if c == false && message['consumed']

      if hook.is_a?(Flor::Trap)
        return false if message['point'] == 'trigger'
        return false if hook.within_itself?(executor, message)
      end

      ps = o(opts, :point, :p, [])
      return false if ps && ! ps.include?(message['point'])

      if nid = o(opts, :nid)
        return false \
          unless nid.include?(message['nid'])
      end

      if exi = o(opts, :exid)
        return false \
          unless message['exid'] == exi
      end

      dm = Flor.domain(message['exid'])

      if dm && ds = o(opts, :domain, :d, [])
        return false \
          unless ds.find { |d| d.is_a?(Regexp) ? (!! d.match(dm)) : (d == dm) }
      end

      if dm && sds = o(opts, :subdomain, :sd, [])
        return false \
          unless sds.find do |sd|
            dm[0, sd.length] == sd
          end
      end

      if ts = o(opts, :tag, :t, [])
        return false unless %w[ entered left ].include?(message['point'])
        return false unless (message['tags'] & ts).any?
      end

      if ns = o(opts, :name, :n)
        return false unless ns.include?(message['name'])
      end

      node = nil

      if hook.is_a?(Flor::Trap) && o(opts, :subnid)
        if node = executor.node(message['nid'], true)
          return false unless node.descendant_of?(hook.bnid, true)
          node = node.h
        else
          return false if hook.bnid != '0'
        end
      end

      if hps = o(opts, :heap, :hp, [])
        return false unless node ||= executor.node(message['nid'])
        return false unless hps.include?(node['heap'])
      end

      if hts = o(opts, :heat, :ht, [])
        return false unless node ||= executor.node(message['nid'])
        return false unless hts.include?(node['heat0'])
      end

      true
    end
  end
end

