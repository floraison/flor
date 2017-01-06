
Gem::Specification.new do |s|

  s.name = 'flor'

  s.version = File.read(
    File.expand_path('../lib/flor.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'http://github.com/floraison'
  #s.rubyforge_project = 'flor'
  s.license = 'MIT'
  s.summary = 'a workflow engine'

  s.description = %{
A Ruby workflow engine
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'munemo', '>= 1.0.1'
  s.add_runtime_dependency 'raabro', '>= 1.1.2'
  #s.add_runtime_dependency 'rufus-lru', '>= 1.1.0'
  s.add_runtime_dependency 'fugit', '>= 0.9.4'

  s.add_development_dependency 'rspec', '3.4.0'
  s.add_development_dependency 'sequel', '~> 4'

  s.require_path = 'lib'
end

