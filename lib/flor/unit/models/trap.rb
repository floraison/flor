
module Flor

  class Trap < FlorModel

    def to_hook

      opts = {}

      opts[:consumed] = tconsumed

      opts[:point] = tpoints.split(',') if tpoints
      opts[:tag] = ttags.split(',') if ttags
      opts[:heap] = do_split(theaps) if theaps
      opts[:heat] = do_split(theats) if theats

      opts[:name] = data['names']

      case trange
        when 'execution'
          opts[:exid] = exid
        when 'subdomain'
          opts[:subdomain] = Flor.domain(exid)
        when 'domain'
          opts[:domain] = Flor.domain(exid)
        else #'subnid' # default
          opts[:exid] = exid
          opts[:subnid] = true
      end

      [ "trap#{id}", opts, self, nil ]
    end

    def trigger(executor, message)

      [ decrement, [ to_trigger_message(executor, message) ] ]
    end

    def within_itself?(executor, message)

      return false if message['exid'] != exid

      n = executor.node(message['from'] || message['nid'], true)
      return false if n == nil

      n.descendant_of?(onid)
    end

    protected

    # returns true if the trap should be removed from the execution's list
    # of traps
    #
    def decrement

      c = data['count']
      return false unless c

      c = c - 1
      data['count'] = c
      self[:status] = c > 0 ? 'active' : 'consumed'

      self.update(content: Flor::Storage.to_blob(@data), status: self[:status])

      c < 1
    end

    def to_trigger_message(executor, message)

      dat = self.data(false)
      msg = dat['message']

      msg['trap_id'] = self.id

      if vs = msg['vars']

        k = vs.keys.find { |k| k != 'arguments' } || 'msg'
        vs[k] = message

        if sig = message['point'] == 'signal' && message['name']
          vs['sig'] = sig
        end
      end

      if dat['pl'] == 'event'
        (msg['vars'] ||= {})['payload'] = msg['payload']
        msg['payload'] = Flor.dup(message['payload'])
      end

      { 'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.nid,
        'type' => 'trap',
        'trap' => to_hash,
        'trap_id' => self.id,
        'message' => msg,
        'sm' => message['m'] }
            #'dbg' => xx
          #.tap { |m| pp m['message'] }
          #.tap { |m| pp m }
    end

    def to_hash

      values
        .inject({}) { |h, (k, v)| h[k.to_s ] = v if k != :content; h }
    end

    def do_split(v)

      v
        .split(',')
        .collect { |e| Flor.is_regex_string?(e) ? Flor.to_regex(e) : e }
    end
  end
end

