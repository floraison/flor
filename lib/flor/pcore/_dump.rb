# frozen_string_literal: true

class Flor::Pro::Dump < Flor::Procedure

  name '_dump'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    if n = @execution['nodes']['0']

      dump = {}

      dump['message'] = Flor.dup(@message)
      dump['node'] = Flor.dup(@node)

      vars = {}
      pn = @node
      while pn
        if vs = pn['vars']
          vs.each { |k, v| vars[k] = Flor.dup(v) unless vars.has_key?(k) }
        end
        pn = @execution['nodes'][pn['parent']]
      end
      dump['vars'] = vars

      (n['vars']['dumps'] ||= []) << dump
    end

    super
  end
end

