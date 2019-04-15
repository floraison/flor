
#
# specifying flor
#
# Mon Apr 15 10:51:30 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  class TheoTasker < Flor::BasicTasker

    def on_task
      # do nothing, just sit here
      []
    end

    def on_cancel
      reply(theo_cancel: true)
    end
  end

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'u_taskers'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    @unit.add_tasker('theo', TheoTasker)
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker' do

    context 'when its node gets cancelled' do

      it 'receives a cancel message' do

        r = @unit.launch(
          %q{
            theo 'take out the garbage'
          },
          wait: '0 receive; 0 receive')

        wait_until { @unit.executions.count > 0 }

        @unit.cancel(r['exid'])

        r = @unit.wait(r['exid'], 'terminated')

        expect(r['payload']['theo_cancel']).to eq(true)
      end
    end
  end
end

