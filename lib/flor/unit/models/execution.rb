# frozen_string_literal: true

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
    def closing_messages; data['closing_messages']; end

    def execution(reload=false); self; end

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
      tree1 = nil

      nodes.each do |nid, n|

        next if nid == '0'
        t = n['tree']; next unless t

        tree1 ||= Flor.dup(tree)
        snid = n['parent'].split('-')[0].split('_').collect(&:to_i)
        cid = snid.pop
        ptree = get_tree(tree1, snid)
        ptree[1][cid] = t
      end

      tree1 || tree
    end

    def lookup_tree(nid)

      Flor::Node.new(self.data, nodes[nid], nil)
        .lookup_tree(nid)
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

      cs[:failures] = 0
      cs[:tasks] = 0
      cs[:nodes] = nodes.count
        #
      nodes.each do |k, v|
        if v['task']
          cs[:tasks] += 1
          is[:tasks] << k
        end
        if v['failure']
          cs[:failures] += 1
          is[:failures] << k
        end
      end

      h[:tree] = full_tree

      h
    end

    def lookup_nodes(query, opts={})

      @node_index ||= nodes
        .sort_by { |k, _| k }
        .inject({}) { |h, (k, v)|
          #
          # nid => [ node ]
          #
          h[k] = [ v ]
          #
          # code => [ node0, node1, ... ]
          #
          t =
            (lookup_tree(v['parent'])[1][Flor.child_id(v['nid'])] rescue nil) ||
            lookup_tree(v['nid'])
          s = Flor.tree_to_flor(t, chop: true)
          (h[s] ||= []) << v
          #
          # tag => [ node0, node1, ... ]
          #
          ts = v['tags']
          ts.each { |t| (h[t] ||= []) << v } if ts
          #
          h }

      @node_index
        .select { |k, v|
          case query
          when Regexp then k.match(query)
          else k == query
          end }
        .values
        .flatten(1)
    end

    def lookup_node(query, opts={})

      lookup_nodes(query, opts).first
    end

    def lookup_nids(query, opts={})

      lookup_nodes(query, opts).collect { |n| n['nid'] }
    end

    def lookup_nid(query, opts={})

      lookup_node(query, opts)['nid']
    end

    protected

    def get_tree(tree, split_nid)

      split_nid.empty? ? tree : get_tree(tree[1][split_nid.shift], split_nid)
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

