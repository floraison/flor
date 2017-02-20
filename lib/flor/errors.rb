
class Flor::FlorError < StandardError

  attr_reader :node

  def initialize(message, node=nil)

    super(message)
    @node = node
  end
end

