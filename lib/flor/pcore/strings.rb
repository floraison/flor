
class Flor::Pro::Strings < Flor::Procedure

  names %w[
    downcase lowercase upcase uppercase
    capitalize ]

  # TODO snake_case, CamelCase, etc

  def receive_last

    met =
      case @node['heat0']
      when 'downcase', 'lowercase' then :downcase
      when 'upcase', 'uppercase' then :upcase
      when 'capitalize' then :capitalize
      else :to_s
      end

    payload['ret'] = process(payload['ret'], met)

    wrap
  end

  protected

  def process(o, met)

    case o
    when String then o.send(met)
    when Array then o.collect { |e| process(e, met) }
    when Hash then o.inject({}) { |h, (k, v)| h[k] = process(v, met); h }
    else o
    end
  end
end

