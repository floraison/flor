
require 'flor/pcore/iterator'


class Flor::Pro::All < Flor::Pro::Iterator

  name 'all?'

  protected

  def pre_iterator

    # nothing to do
  end

  def receive_iteration

    # nothing to do
  end

  def iterator_over?

    super ||
    (@node['idx'] > 0 && ( ! Flor.true?(payload['ret'])))
  end

  def iterator_result

    Flor.true?(payload['ret'])
  end
end

