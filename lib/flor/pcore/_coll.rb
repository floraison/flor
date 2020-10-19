# frozen_string_literal: true

class Flor::Pro::Coll < Flor::Procedure

  protected

  def atomic?(child_tree)

    t0, t1 = child_tree

    return false if t1.is_a?(Array)
    return false if t0 == '_dqs' && t1.index('$(')
    return false if t0 == '_rxs'
    return false if t0 == '_func'

    Flor::Pro::Atom.names.include?(t0)
  end
end

