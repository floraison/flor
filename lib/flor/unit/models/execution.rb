
module Flor

  class Execution < FlorModel

    def nodes; data['nodes']; end
    def zero_node; nodes['0']; end

    def tags

      data['nodes'].values.inject([]) do |a, n|
        if ts = n['tags']; a.concat(ts); end
        a
      end
    end

    def failed?

      !! nodes.values
        .find { |n| n['failure'] && n['status'] != 'triggered-on-error' }
    end

    def failed_nodes

      nodes.values
        .select { |n| n['failure'] && n['status'] != 'triggered-on-error' }
    end

    def full_tree

      tree = nodes['0']['tree']

      nodes.each do |nid, n|
        next if nid == '0'
        t = n['tree']; next unless t
      end

      tree
    end

    def zero_variables

      zero_node['vars']
    end

    # class methods

    def self.by_status(s)

      self.where(status: s)
    end

    def self.terminated

      by_status('terminated')
    end

    def self.by_tag(name)

      _exids = self.db[:flor_pointers]
        .where(type: 'tag', name: name, value: nil)
        .select(:exid)
        .distinct

      self.where(status: 'active', exid: _exids)
    end

    def self.by_var(name, value=:no)

      w = { type: 'var', name: name }

      case value; when nil
        w[:value] = nil
      when :no
        # no w[:value] "constraining"
      else
        w[:value] = value.to_s
      end

      _exids = self.db[:flor_pointers]
        .where(w)
        .select(:exid)
        .distinct

      self.where(status: 'active', exid: _exids)
    end

    def self.by_tasker(name, taskname=:no)

      w = { type: 'tasker', name: name }
      w[:value] = taskname if taskname != :no

      _exids = self.db[:flor_pointers]
        .where(w)
        .select(:exid)
        .distinct

      self.where(status: 'active', exid: _exids)
    end

#    def self.by_task(name)
#    end
  end
end

