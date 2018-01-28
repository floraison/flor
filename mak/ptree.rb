
$: << 'lib'

require 'json'

require 'flor/unit'


p Flor::Pro::Sequence.public_methods.sort
#p Flor::Pro::Sequence.constants

index = Flor::Pro.constants
  .inject({}) { |h, c|
    c = Flor::Pro.const_get(c)
    next h unless c.respond_to?(:names)
    as = (c.ancestors.select { |cl| cl.to_s.match(/^Flor::/) } - [ Flor::Node ])
    ns = c.names
    h[c] = { class: c, ancestors: as, names: c.names }
    h }
classes = index.values
  .collect { |p| p[:ancestors] }
  .flatten
  .uniq
#classes = classes - [ Flor::Procedure ]
parents = index
  .inject({}) { |h, (k, v)|
    list = v[:ancestors].reverse
    loop do
      parent = list.shift
      break unless list.any?
      h[parent] ||= []
      h[parent] = (h[parent] + [ list.first ]).uniq
    end
    h }

#pp index
#pp classes
pp parents

