
class Flor::Pro::Ccollect < Flor::IteratorMacro

  name 'ccollect'

  def rewrite_tree

    rewrite_iterator_tree('cmap')
  end
end

