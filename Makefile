
## gem tasks ##

NAME = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.name")
VERSION = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.version")


gemspec_validate:
	@echo "---"
	ruby -e "s = eval(File.read(Dir['*.gemspec'].first)); s.validate"
	@echo "---"

name: gemspec_validate
	@echo "$(NAME) $(VERSION)"

build: gemspec_validate
	gem build $(NAME).gemspec
	mkdir -p pkg
	mv $(NAME)-$(VERSION).gem pkg/

push: build
	gem push pkg/$(NAME)-$(VERSION).gem


## flor tasks ##

RUBY=bundle exec ruby
FLOR_ENV?=dev

migrate:
	$(RUBY) -Ilib -e "require 'flor/unit'; Flor::Unit.new('.flor-$(FLOR_ENV).conf').storage.migrate"

start:
	$(RUBY) -Ilib -e "require 'flor/unit'; Flor::Unit.new('.flor-$(FLOR_ENV).conf').start.join"
s: start

