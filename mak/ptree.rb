
$: << 'lib'

require 'json'

require 'flor/unit'

GURI = 'https://github.com/floraison/flor/blob/master/'

INDEX = (
  [ Flor::Procedure, Flor::Macro ] +
  Flor::Pro.constants.collect { |c| Flor::Pro.const_get(c) }
)
  .inject({}) { |h, c|
    next h unless c.respond_to?(:names)
    as = (c.ancestors.select { |cl| cl.to_s.match(/^Flor::/) } - [ Flor::Node ])
    ns = c.names
    h[c] = { class: c, ancestors: as, names: c.names }
    h }
INDEX
  .each { |k, v|
    a = v[:ancestors][1]
    a = INDEX[a]
    next unless a
    (a[:children] ||= []) << k }

Dir['lib/flor/{pcore,punit}/*.rb']
  .each { |path|
    m = File.read(path).match(/^class (Flor::.+) < /)
    k = Flor.const_lookup(m[1])
    INDEX[k][:spath] = path }
Dir['doc/procedures/*.md']
  .each { |path|
    s = File.read(path)
    m = s.match(/^# ([- ,a-z0-9]+)/)
    next unless m
    names = m[1].split(/, */)
    INDEX.values.each { |h|
      next unless ((h[:names] || []) & names).any?
      h[:dpath] = path } }

def render(level, klass)

  d = INDEX[klass]
  ns = d[:names]
  dp = d[:dpath]

  print "#{'  ' * level}* [#{klass}](#{GURI}#{d[:spath]})"
  if ns && dp
    print " [#{ns.join(', ')}](#{dp})"
  elsif ns
    print " #{ns.join(', ')}"
  end
  puts

  (d[:children] || [])
    .sort_by { |c| c.to_s }
    .each { |c| render(level + 1, c) }
end
render(0, Flor::Procedure)

