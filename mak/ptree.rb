
$: << 'lib'

require 'json'

require 'flor/unit'


index = (
  [ Flor::Procedure, Flor::Macro ] +
  Flor::Pro.constants.collect { |c| Flor::Pro.const_get(c) }
)
  .inject({}) { |h, c|
    next h unless c.respond_to?(:names)
    as = (c.ancestors.select { |cl| cl.to_s.match(/^Flor::/) } - [ Flor::Node ])
    ns = c.names
    h[c] = { class: c, ancestors: as, names: c.names }
    h }
index
  .each { |k, v|
    a = v[:ancestors][1]
    a = index[a]
    next unless a
    (a[:children] ||= []) << k }

#pp index
#pp classes
#pp parents
#pp index[Flor::Procedure]
#pp index[Flor::Macro]

def render(index, level, klass)
  d = index[klass]
  print "#{'  ' * level}* #{klass}"
  if ns = d[:names]
    print ' '
    print d[:names].collect { |n| "[#{n}](#{n}.md)" }.join(', ')
  end
  puts
  (d[:children] || [])
    .sort_by { |c| c.to_s }
    .each { |c| render(index, level + 1, c) }
end
render(index, 0, Flor::Procedure)

