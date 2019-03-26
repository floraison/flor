
## gem tasks ##

NAME = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.name")
VERSION = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.version")

count_lines:
	find lib -name "*.rb" | xargs cat | ruby -e "p STDIN.readlines.count { |l| l = l.strip; l[0, 1] != '#' && l != '' }"
	find spec -name "*_spec.rb" | xargs cat | ruby -e "p STDIN.readlines.count { |l| l = l.strip; l[0, 1] != '#' && l != '' }"
cl: count_lines

gemspec_validate:
	@echo "---"
	ruby -e "s = eval(File.read(Dir['*.gemspec'].first)); p s.validate"
	@echo "---"

name: gemspec_validate
	@echo "$(NAME) $(VERSION)"

cw:
	find lib -name "*.rb" -exec ruby -cw {} \; | grep lib

syncver:
	sed -E -i '' "s/VERSION = ['0-9.]+/VERSION = '$(shell grep -E "$(NAME) ([0-9.]+)" CHANGELOG.md | head -1 | sed -E 's/[^0-9\.]//g')'/" lib/$(NAME).rb
	bundle install

build: gemspec_validate
	gem build $(NAME).gemspec
	mkdir -p pkg
	mv $(NAME)-$(VERSION).gem pkg/

push: build
	gem push pkg/$(NAME)-$(VERSION).gem


## flor tasks ##

RUBY=bundle exec ruby
#RUBY=bundle exec ruby --disable-did_you_mean
  # gem uninstall did_you_mean

FLOR_ENV?=dev
TO?=nil
FROM?=nil


migrate:
	$(RUBY) -Ilib -e "require 'flor/unit'; Flor::Unit.new('envs/$(FLOR_ENV)/etc/conf.json').storage.migrate($(TO), $(FROM))"

start:
	$(RUBY) -Ilib -e "require 'flor/unit'; Flor::Unit.new('envs/$(FLOR_ENV)/etc/conf.json').start.join"
#s: start


## misc tasks ##

backup_notes_and_todos:
	tar czvf flor_notes_$(shell date "+%Y%m%d_%H%M").tgz .notes.md .todo.md && mv flor_notes_*.tgz ~/Dropbox/backup/
ba: backup_notes_and_todos
backup_src:
	cd .. && tar czvf flor_$(shell date "+%Y%m%d_%H%M").tgz flor && mv flor_*.tgz ~/Dropbox/backup/
bak: backup_src

t:
	tree spec/unit/loader

mk:
	# testing lib/flor/tools/env.rb
	$(RUBY) -Ilib -e "require 'flor/tools/env'; Flor::Tools::Env.make('tmp', '$(FLOR_ENV)', gitkeep: true)"

doc:
	$(RUBY) -Imak -r 'doc_procedures' -e "make_doc_procedures()"
doct:
	@$(RUBY) mak/ptree.rb

shell:
	$(RUBY) -Ilib -r 'flor/tools/shell' -e 'Flor::Tools::Shell.new'
sh: shell

cleanshell:
	rm -f envs/shell/var/flor.db
	rm -fR envs/shell/var/tasks/*
	rm -f .log.txt

.PHONY: \
  count_lines gemspec_validate name cw build push spec doc shell cleanshell

