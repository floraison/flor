
class Flor::Pro::Ceach < Flor::Macro::Iterator

  names %w[ ceach c-each ]

  def rewrite_tree

    rewrite_iterator_tree('c-for-each')
  end
end

