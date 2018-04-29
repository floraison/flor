
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
  s.summary = 'A Ruby workflow engine'

  s.description = %{
A Ruby workflow engine (ruote next generation)
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  s.add_runtime_dependency 'munemo', '>= 1.0.1'
  s.add_runtime_dependency 'raabro', '>= 1.1.5'
  #s.add_runtime_dependency 'rufus-lru', '>= 1.1.0'
  s.add_runtime_dependency 'fugit', '>= 1.1.0'
  s.add_runtime_dependency 'dense', '~> 1.1'

  s.add_runtime_dependency 'sequel', '~> 4'

  s.add_development_dependency 'rspec', '3.4.0'
  s.add_development_dependency 'terminal-table'

  s.require_path = 'lib'
end

