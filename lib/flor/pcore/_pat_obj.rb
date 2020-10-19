# frozen_string_literal: true

require 'flor/pcore/_pat_'


class Flor::Pro::PatObj < Flor::Pro::PatContainer

  name '_pat_obj'

  def pre_execute

    @node['atts'] = []

    t = tree

    if (
      i = t[1].index { |ct|
         ct[0] == '_att' &&
         ct[1].size == 1 &&
         ct[1][0][0, 2] == [ 'only', [] ] }
    ) then
      t[1][i] =
        [ '_att', [
          [ '_sqs', 'only', -1 ],
          [ '_boo', true, -1 ],
        ], *t[1][i][2..-1] ]
      @node['tree'] = [ t[0], t[1], *t[1][2..-1] ]
    end

    t = tree
    changed = false
    t[1].each_with_index do |ct, j|
      next if j.odd? || ct[0] != '_ref'
      ct[0] = '_rep'
      changed = true
    end
    @node['tree'] = t if changed

    super
  end

  def receive_first

    return wrap_no_match_reply unless val.is_a?(Hash)

    super
  end

  def receive_last_att

    rewrite_keys

    @node['key'] = nil
    @node['keys'] = [] if att('only')

    super
  end

  def receive_non_att

    key = @node['key']
    ret = payload['ret']

    unless key
      return wrap_no_match_reply unless Dense.has_key?(val, Array(ret))
      @node['key'] = ret
      @node['keys'] << ret if @node['keys']
      return super
    end

    ct = child_type(@fcid)

    if ct == :pattern

      if b = payload.delete('_pat_binding')
        @node['binding'].merge!(b)
      else
        return wrap_no_match_reply
      end

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['key']] if ct != '_'

    elsif ct.is_a?(Array)

      @node['binding'][ct[0]] = val[@node['key']] if ct[0].length > 0

    elsif Dense.get(val, key) != ret

      return wrap_no_match_reply
    end

    @node['key'] = nil

    super
  end

  def receive_last

    ks = @node['keys']
    return wrap_no_match_reply if ks && val.keys.sort != ks.sort

    payload['_pat_binding'] = @node['binding']
    payload.delete('_pat_val')

    super
  end

  protected

  def rewrite_keys

    q = (att('quote') == 'keys')

    key = true

    cn = children
      .collect { |ct|
        next ct if ct[0] == '_att'
        key = ! key
        next ct if key
        q ? quote_key(ct) : lookup_and_quote_key(ct) }

    t = tree

    @node['tree'] = [ t[0], cn, *t[2..-1] ] if cn != t[1]
  end

  def quote_key(t)

    if t[1] == []
      [ '_sqs', t[0], *t[2..-1] ]
    elsif t[1].is_a?(Array)
      t
    else
      [ '_sqs', t[1].to_s, *t[2..-1] ]
    end
  end

  def lookup_and_quote_key(t)

    return t unless t[1] == []
    [ '_sqs', (lookup_value(t[0]) rescue t[0]), t[2] ]
  end

  def sub_val(child_index)

    [ 1, Dense.get(val, @node['key']) ]
  end
end

