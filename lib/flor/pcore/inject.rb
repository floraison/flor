
require 'flor/pcore/iterator'


class Flor::Pro::Inject < Flor::Macro::Iterator

  name 'inject'

  def rewrite_tree

    rewrite_iterator_tree('reduce')
  end
end

