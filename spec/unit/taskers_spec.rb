
#
# specifying flor
#
# Mon Apr 15 10:51:30 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'u_taskers'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker' do

    describe '#reply' do

      it 'returns the message as is by default' do

        class UtZeroTasker < Flor::BasicTasker
          def on_task
            reply
          end
        end

        @unit.add_tasker('alice', UtZeroTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 1 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('ret' => 'alice', 'a' => 0, 'b' => 1)
      end

      it 'returns a given payload:' do

        class UtOneTasker < Flor::BasicTasker
          def on_task
            reply(payload: { c: 2 })
          end
        end

        @unit.add_tasker('alice', UtOneTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 1 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('c' => 2)
      end

      it 'returns a given ret:' do

        class UtTwoTasker < Flor::BasicTasker
          def on_task
            reply(ret: 'ritorno')
          end
        end

        @unit.add_tasker('alice', UtTwoTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 1 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('ret' => 'ritorno', 'a' => 0, 'b' => 1)
      end

      it 'understands set: and unset:' do

        class UtThreeTasker < Flor::BasicTasker
          def on_task
            reply(ret: 'ritorno', set: { a: -1 }, unset: [ :b ])
          end
        end

        @unit.add_tasker('alice', UtThreeTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 1 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('ret' => 'ritorno', 'a' => -1)
      end
    end

    context 'when its node gets cancelled' do

      it 'receives a cancel message' do

        class CarmenTasker < Flor::BasicTasker
          def on_task
            # do nothing, just sit here
            []
          end
          def on_cancel
            reply(theo_cancel: true)
          end
        end

        @unit.add_tasker('carmen', CarmenTasker)

        r = @unit.launch(
          %q{
            carmen 'take out the garbage'
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

