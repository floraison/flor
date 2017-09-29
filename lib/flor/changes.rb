
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
    when 'add' then Dense.insert(h, c['path'], c['value'])
    when 'replace' then Dense.set(h, c['path'], c['value'])
    when 'remove' then Dense.unset(h, c['path'])
    end
  end
end

