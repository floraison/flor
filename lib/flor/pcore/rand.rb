
class Flor::Pro::Rand < Flor::Procedure
  #
  # Returns a randomly generated number.
  #
  # ```
  # rand 10        # returns an integer i, 0 <= i < 10
  # rand 10.0      # returns a float f, 0.0 <= f < 10.0
  # rand 1 11      # returns an integer i, 1 <= i < 11
  # rand 1.0 11    # returns a float f, 1.0 <= f < 11.0
  # rand 1 11.0    # returns a float f, 1.0 <= f < 11.0
  # rand 1.0 11.0  # returns a float f, 1.0 <= f < 11.0
  # ```
  #
  # When give no argument, it simply takes the current `payload['ret']`
  # ```
  # sequence
  #   10
  #   rand  # returns an integer i, 0 <= i < 10
  # ```

  name 'rand'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    a, b = determine_bounds

    fail ArgumentError.new(
      "'rand' expects an integer or a float"
    ) unless is_number?(a) && is_number?(b)

    payload['ret'] = Random.rand(a...b)

    reply
  end

  protected

  def is_number?(o)

    o.is_a?(Integer) || o.is_a?(Float)
  end

  def determine_bounds

    nums = @node['atts']
      .inject([]) { |a, (k, v)| a << v if k.nil? && is_number?(v); a }

    return nums[0, 2] if nums.size > 1
    return [ 0, nums.first ] if nums.size == 1
    [ 0, payload['ret'] ]
  end
end

