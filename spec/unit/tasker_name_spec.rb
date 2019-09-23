
#
# specifying flor
#
# Mon Sep 23 22:39:08 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'u_tasker_name'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    class TaskerNameTasker < Flor::BasicTasker
      def task
        #puts '=' * 80
        #puts "== #{taskname}"
        reply
      end
    end
    @unit.add_tasker(:alice, TaskerNameTasker)
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker name' do

    it 'is resolved to a tasker call' do

      # gh-30
      # Many thanks to Ryan Scott @Subtletree
      # for reporting this issue

      exid =
        @unit.launch(%q{
define one
  trace _
define two
  trace _
define three
  trace _
define four
  trace _
define five
  trace _
define six
  trace _
define seven
  trace _
define eight
  trace _
define nine
  trace _
define ten
  trace _                                       # Error goes away with any of the below changes....
define eleven                                   # works removing any function, one to eleven
  trace _
#define twelve                                  # works adding a new function
#  trace _

set some_var true                               # works removing the set
on 'some_trap' count: 1                         # works removing this trap or even just the count
  alice 'baz'
concurrence
  sequence                                      # works removing the sequence
    alice 'this one breaks' unless f.some_prop  # works removing the unless
    #task 'alice' 'foo'  unless f.some_prop     # works using `task 'alice' 'foo'` syntax instead of `alice 'foo'`
  alice 'working branch'                        # works removing the other concurrent branch
  })

      r = @unit.wait(exid, 'terminated')

      expect(r['point']).to eq('terminated')

      expect(
        @unit.journal
          .select { |m| m['point'] == 'task' }
          .collect { |m| m['nid'] }
      ).to eq(%w[
        0_13_1
        0_13_0_0_1
      ])
    end
  end
end

