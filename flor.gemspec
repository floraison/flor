
Gem::Specification.new do |s|

  s.name = 'flor'

  s.version = File.read(
    File.expand_path('../lib/flor.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://github.com/flon-io/flor'
  #s.rubyforge_project = 'flor'
  s.license = 'MIT'
  s.summary = 'the flon programs, in Ruby'

  s.description = %{
the flon programs, in Ruby
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'munemo'
  s.add_runtime_dependency 'raabro', '>= 1.0.5'
  s.add_runtime_dependency 'sequel', '>= 4.29.0'

  s.add_development_dependency 'rspec', '3.4.0'

  s.require_path = 'lib'
end

