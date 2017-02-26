
module Flor

  # deep.rb
  #
  # functions for deep getting/setting in structures

  def self.to_array_index(o)

    return 0 if o == 'first'
    return -1 if o == 'last'
    return o if o.is_a?(Integer)
    nil
  end

  def self.split_deep_path(k)

    return k if k.is_a?(Array)

    k
      .scan(/(?:\.?(-?\d+)|\.?([^\.\[]+)|\[(-?\d+)\]|\[([^\[\]]+)\])/)
      .collect { |doti, dots, squi, squs|
        if doti
          doti.to_i
        elsif dots
          dots
        elsif squi
          squi.to_i
        else
          s0 = squs[0, 1]
          (s0 == "'" || s0 == '"') ? squs[1..-2] : squs
        end }
  end

  def self.deep_get(o, k) # --> success(boolean), value

    return [ true, o ] unless k

    val = o

    split_deep_path(k).each do |kk|

      case val
      when Array
        i = to_array_index(kk)
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

    ks = split_deep_path(k)
    key = ks.pop

    b, col = deep_get(o, ks)

    return [ false, v ] unless b

    case col
    when Array
      i = to_array_index(key)
      return [ false, v ] unless i
      col[i] = v
    when Hash
      col[key] = v
    else
      return [ false, v ]
    end

    [ true, v ]
  end

  def self.deep_insert(o, k, v) # --> [ success(boolean), value ]

    ks = split_deep_path(k)
    key = ks.pop

    b, col = deep_get(o, ks)

    return [ false, nil ] unless b

    case col
    when Array
      i = to_array_index(key)
      return [ false, v ] unless i
      col.insert(i, v)
    when Hash
      col[key] = v
    else
      return [ false, v ]
    end

    [ true, v ]
  end

  def self.deep_unset(o, k) # --> [ success(boolean), value ]

    ks = split_deep_path(k)
    key = ks.pop

    b, col = deep_get(o, ks)

    return [ false, nil ] unless b

    v =
      case col
      when Array
        i = to_array_index(key)
        return [ false, nil ] unless i
        col.delete_at(i)
      when Hash
        col.delete(key)
      else
        return [ false, nil ]
      end

    [ true, v ]
  end

  def self.deep_has_key?(o, k)

    val = o
    ks = split_deep_path(k)

    loop do

      kk = ks.shift

      case val
      when Array
        i = to_array_index(kk)
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

