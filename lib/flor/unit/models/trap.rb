
module Flor

  class Trap < FlorModel

    #create_table :flor_traps do
    #
    #  primary_key :id, type: :Integer
    #  String :domain, null: false
    #  String :exid, null: false
    #  String :onid, null: false
    #  String :nid, null: false
    #  #
    #  TrueClass :tconsumed, null: false, default: false
    #  String :trange, null: false
    #  String :tpoints, null: true
    #  String :ttags, null: true
    #  String :theats, null: true
    #  String :theaps, null: true
    #  #
    #  File :content # JSON msg to trigger
    #  #
    #  String :status, null: false
    #  String :ctime, null: false
    #  String :mtime, null: false
    #
    #  String :cunit
    #  String :munit
    #
    #  String :bnid, null: false
    #
    #  index :exid
    #  index [ :exid, :nid ]
    #end

    def to_hook

      opts = {}

      opts[:consumed] = tconsumed

      opts[:point] = tpoints.split(',') if tpoints
      opts[:tag] = do_split(ttags) if ttags
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
      self[:status] = s = (c > 0) ? 'active' : 'consumed'

      self.update(
        content: Flor::Storage.to_blob(@flor_model_cache_data),
        status: s)

      c < 1
    end

    def to_trigger_message(executor, message)

      dat = self.data(false)
      msg = dat['message']

      msg['trap_id'] = self.id

      args = msg['arguments'] = [ [ 'msg', message ] ]

      if sig = (message['point'] == 'signal' && message['name'])
        args << [ 'sig', sig ]
      end

      case pl = dat['pl']
      when 'event'
        args << [ 'payload', msg['payload'] ]
        msg['payload'] = Flor.dup(message['payload'])
      #when 'trap'
      when Hash
        msg['payload'] = Flor.dup(pl)
      #else
      end

      { 'point' => 'trigger',
        'exid' => self.exid,
        'nid' => self.nid,
        'type' => 'trap',
        'trap' => to_hash,
        'trap_id' => self.id,
        'message' => msg,
        'sm' => message['m'] }
#.tap { |m| pp m }
#.tap { |m| pp m['message'] }
            #'dbg' => xx }
    end

    def to_hash

      values
        .inject({}) { |h, (k, v)| h[k.to_s] = v if k != :content; h }
    end

    def do_split(v)

      v
        .split(',')
        .collect { |e| Flor.is_regex_string?(e) ? Flor.to_regex(e) : e }
    end
  end
end

