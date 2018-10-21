
module Flor

  class Execution < FlorModel

    #create_table :flor_executions do
    #
    #  primary_key :id, type: :Integer
    #  String :domain, null: false
    #  String :exid, null: false
    #  File :content # JSON
    #  String :status, null: false # 'active' or something else like 'archived'
    #  String :ctime, null: false
    #  String :mtime, null: false
    #  String :cunit
    #  String :munit
    #
    #  index :exid
    #end

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

    def to_h

      h = super

      h[:size] = self[:content].size

      m = h[:meta] = {}
      cs = m[:counts] = {}
      is = m[:nids] = { tasks: [], failures: [] }

      fs = 0
      ts = 0
      nodes.each do |k, v|
        if v['task']
          ts += 1
          is[:tasks] << k
        end
        if v['failure']
          fs += 1
          is[:failures] << k
        end
      end
      cs[:nodes] = nodes.count
      cs[:failures] = fs
      cs[:tasks] = ts

      h
    end

    class << self

      def by_status(s)

        where(status: s)
      end

      def terminated

        by_status('terminated')
      end

      def by_tag(name)

        _exids = db[:flor_pointers]
          .where(type: 'tag', name: name, value: nil)
          .select(:exid)
          .distinct

        where(status: 'active', exid: _exids)
      end

      def by_var(name, value=:no)

        w = { type: 'var', name: name }

        case value; when nil
          w[:value] = nil
        when :no
          # no w[:value] "constraining"
        else
          w[:value] = value.to_s
        end

        _exids = db[:flor_pointers]
          .where(w)
          .select(:exid)
          .distinct

        where(status: 'active', exid: _exids)
      end

      def by_tasker(name, taskname=:no)

        w = { type: 'tasker', name: name }
        w[:value] = taskname if taskname != :no

        _exids = db[:flor_pointers]
          .where(w)
          .select(:exid)
          .distinct

        where(status: 'active', exid: _exids)
      end

#      def by_task(name)
#      end
    end
  end
end

