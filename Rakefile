
require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rdoc/task'


#
# clean

CLEAN.include('pkg', 'rdoc')


#
# test / spec

#task :spec => :check_dependencies do
task :spec do
  exec 'rspec spec/'
end
task :test => :spec

task :default => :spec


#
# gem

GEMSPEC_FILE = Dir['*.gemspec'].first
GEMSPEC = eval(File.read(GEMSPEC_FILE))
GEMSPEC.validate


desc %{
  builds the gem and places it in pkg/
}
task :build do

  sh "gem build #{GEMSPEC_FILE}"
  sh "mkdir -p pkg"
  sh "mv #{GEMSPEC.name}-#{GEMSPEC.version}.gem pkg/"
end

desc %{
  builds the gem and pushes it to rubygems.org
}
task :push => :build do

  sh "gem push pkg/#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
end

