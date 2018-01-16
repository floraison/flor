
require 'flor/pcore/iterator'


class Flor::Pro::All < Flor::Pro::Iterator

  name 'all?'

  protected

  def receive_iteration

    # nothing to do
  end

  def function_mandatory?

    false
  end

  def no_iterate

    ret =
      case col = @node['ocol']
      when Array then col.all?
      when Hash then col.values.all?
      else false
      end

    wrap_reply('ret' => ret)
  end

  def iterator_over?

    super ||
    (@node['idx'] > 0 && ( ! Flor.true?(payload['ret'])))
  end

  def iterator_result

    Flor.true?(payload['ret'])
  end
end

