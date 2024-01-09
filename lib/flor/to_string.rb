# frozen_string_literal: true

module Flor

  # used in procedure, cancel, until, cursor specs
  # when "walking" and "stepping"

  class << self

    def to_s(o=nil, k=nil)

      return 'Flor' if o == nil && k == nil
        # should it emerge somewhere...

      return o.collect { |e| Flor.to_s(e, k) }.join("\n") if o.is_a?(Array)

      if o.is_a?(Hash)

        return send("message_#{k}_to_s", o) if k && o['point'].is_a?(String)
        return message_to_s(o) if o['point'].is_a?(String)

        return send("node_#{k}_to_s", o) if k && o.has_key?('parent')
        return node_to_s(o) if o['parent'].is_a?(String)
      end

      return [ o, k ].inspect if k
      o.inspect
    end

    def message_to_s(m)

      s = StringIO.new
      s << '(msg ' << m['nid'] << ' ' << m['point']
      %w[ from flavour ].each { |k|
        s << ' ' << k << ':' << m[k].to_s if m.has_key?(k) }
      s << ')'

      s.string
    end

    def node_status_to_s(n)

      stas = n['status'].reverse

      s = StringIO.new
      while sta = stas.shift
        s << '(status ' << (sta['status'] || 'o') # o for open
        s << ' pt:' << sta['point']
        if f = sta['flavour']; s << ' fla:' << f; end
        if f = sta['from']; s << ' fro:' << f; end
        if m = sta['m']; s << ' m:' << m; end
        s << ')'
        s << "\n" if stas.any?
      end

      s.string
    end

    def node_to_s(n) # there is already a .node_to_s in log.rb

      n.inspect
    end
  end
end

