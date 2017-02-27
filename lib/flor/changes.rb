
module Flor::Changes
  extend self

  def apply(h, cs)

    #return cs if cs.is_a?(Hash)

    h = Flor.dup(h)
    cs.each { |c| do_apply(h, c) }

    h
  end

  protected

  def do_apply(h, c)

    case c['op']
    when 'add' then Flor.deep_insert(h, c['path'], c['value'])
    when 'replace' then Flor.deep_set(h, c['path'], c['value'])
    when 'remove' then Flor.deep_unset(h, c['path'])
    end
  end
end

