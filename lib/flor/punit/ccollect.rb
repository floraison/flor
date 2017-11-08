
class Flor::Pro::Ccollect < Flor::Macro::Iterator

  name 'ccollect'

  def rewrite_tree

    rewrite_iterator_tree('cmap')
  end
end

