
module Flor

  # deep.rb
  #
  # functions for deep getting/setting in structures

  def self.to_index(s)

    return 0 if s == 'first'
    return -1 if s == 'last'

    i = s.to_i
    return nil if i.to_s != s

    i
  end

  def self.deep_get(o, k) # --> success(boolean), value

    return [ true, o ] unless k

    val = o
    ks = k.split('.')

    loop do

      break unless kk = ks.shift

      case val
        when Array
          i = to_index(kk)
          return [ false, nil ] unless i
          val = val[i]
        when Hash
          val = val[kk]
        else
          return [ false, nil ]
      end
    end

    [ true, val ]
  end

  def self.deep_set(o, k, v) # --> [ success(boolean), value ]

    lastdot = k.rindex('.')
    path = lastdot && k[0..lastdot - 1]
    key = lastdot ? k[lastdot + 1..-1] : k

    b, col = deep_get(o, path)

    return [ false, v ] unless b

    case col
      when Array
        i = to_index(key)
        return [ false, v ] unless i
        col[i] = v
      when Hash
        col[key] = v
      else
        return [ false, v ]
    end

    [ true, v ]
  end

  def self.deep_has_key?(o, k)

    val = o
    ks = k.split('.')

    loop do

      kk = ks.shift

      case val
        when Array
          i = to_index(kk)
          return false unless i
          return (i < 0 ? -i < val.length : i < val.length) if ks.empty?
          val = val[i]
        when Hash
          return val.has_key?(kk) if ks.empty?
          val = val[kk]
        else
          return false
      end
    end
  end
end

