
#
# specifying flor
#
# Mon Nov 23 16:25:25 JST 2020
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'u_sbtasker'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe Flor::StagedBasicTasker do

    describe '#pre_task' do

      it 'is called if present' do

        class SbtZeroTasker < Flor::StagedBasicTasker
          def pre_task
            payload['a'] = 1
          end
          def on_task
            reply
          end
        end

        @unit.add_tasker('alice', SbtZeroTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 0 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('ret' => 'alice', 'a' => 1, 'b' => 0)
      end
    end

    describe '#post_task' do

      it 'is called if present' do

        class SbtOneTasker < Flor::StagedBasicTasker
          def on_task
            reply
          end
          def post_task
            payload['b'] = 1
          end
        end

        @unit.add_tasker('alice', SbtOneTasker)

        r = @unit.launch(%q{ alice _ }, payload: { a: 0, b: 0 }, wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']).to eq('ret' => 'alice', 'a' => 0, 'b' => 1)
      end
    end

    describe '#pre_detask' do

      it 'is called if present' do

        class SbtTwoTasker < Flor::StagedBasicTasker
          def on_task
            # do nothing, just sit here
            []
          end
          def pre_cancel
            payload['x'] = 1
          end
          def on_cancel
            reply
          end
        end

        @unit.add_tasker('tasha', SbtTwoTasker)

        r = @unit.launch(
          %q{ tasha 'study' },
          payload: { 'a' => 0 },
          wait: '0 receive')

        wait_until { @unit.executions.count > 0 }

        @unit.cancel(r['exid'])

        r = @unit.wait(r['exid'], 'terminated')

        expect(r['payload']).to eq({ 'a' => 0, 'x' => 1 })
      end
    end

    describe '#post_detask' do

      it 'is called if present' do

        class SbtThreeTasker < Flor::StagedBasicTasker
          def on_task
            # do nothing, just sit here
            []
          end
          def on_cancel
            reply(
              set: {
                sbt3cancel: true,
                taskname: taskname })
          end
          def post_cancel
            payload['x'] = 1
          end
        end

        @unit.add_tasker('alice', SbtThreeTasker)

        r = @unit.launch(
          %q{
            alice 'pick flowers'
          },
          wait: '0 receive')

        wait_until { @unit.executions.count > 0 }

        @unit.cancel(r['exid'])

        r = @unit.wait(r['exid'], 'terminated')

        expect(r['payload']).to eq({
          'taskname' => 'pick flowers', 'sbt3cancel' => true, 'x' => 1 })
      end
    end
  end
end

