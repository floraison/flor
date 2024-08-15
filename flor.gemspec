
Gem::Specification.new do |s|

  s.name = 'flor'

  s.version = File.read(
    File.expand_path('../lib/flor.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'https://github.com/floraison'
  s.license = 'MIT'
  s.summary = 'A Ruby workflow engine'

  s.metadata = {
    'changelog_uri' => s.homepage + '/flor/blob/master/CHANGELOG.md',
    'documentation_uri' => s.homepage + '/flor/tree/master/doc',
    'bug_tracker_uri' => s.homepage + '/flor/issues',
    'mailing_list_uri' => 'https://groups.google.com/forum/#!forum/floraison',
    'homepage_uri' =>  s.homepage + '/flor',
    'source_code_uri' => s.homepage + '/flor',
    #'wiki_uri' => s.homepage + '/flor/wiki',
  }

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

  #s.add_runtime_dependency 'rufus-lru', '~> 1.1'
  s.add_runtime_dependency 'munemo', '~> 1.0' # >= 1.0 and < 2
  s.add_runtime_dependency 'raabro', '~> 1.1' # >= 1.1 and < 2
  s.add_runtime_dependency 'fugit', '~> 1.10', '>= 1.11.1' # >= 1.2 and < 2
  s.add_runtime_dependency 'dense', '~> 1.1' # >= 1.1 and < 2

  s.add_runtime_dependency 'sequel', '~> 5.0' # >= 5.0 and < 6

  s.add_development_dependency 'rspec', '~> 3.8' # >= 3.8 and < 4
  s.add_development_dependency 'terminal-table', '~> 1.8' # >= 1.8 and < 2

  s.require_path = 'lib'
end

