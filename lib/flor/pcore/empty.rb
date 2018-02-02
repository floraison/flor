
class Flor::Pro::Empty < Flor::Procedure
  #
  # Returns true if the given collection or string is empty.
  #
  # Returns true of the given argument is null, returns false for any
  # other non-collection, non-string argument.
  #
  # ```
  # empty? []           # --> true
  # empty? {}           # --> true
  # empty? ''           # --> true
  # empty? null         # --> true
  #
  # empty? [ 1, 2, 3 ]  # --> false
  # empty? { a: 'A' }   # --> false
  # empty? 0            # --> false
  # empty? 'aaa'        # --> false
  # ```
  #
  # If the argument is not an array, an object, a string or null, an
  # error is triggered.
  #
  # If there is no argument to the "empty?", the incoming payload['ret']
  # is considered
  #
  # ```
  # {}
  # empty? _     # --> true
  #
  # [ 1, 2, 3 ]
  # empty? _     # --> false
  # ```
  #
  # ## see also
  #
  # any?

  name 'empty?'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_last

    ret =
      case r = payload['ret']
      when Array, Hash, String then r.empty?
      when nil then true
      else
        fail Flor::FlorError.new(
          'Argument is not an array, an object, a string or null', self)
      end

    wrap_reply('ret' => ret)
  end
end

