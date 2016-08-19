
#
# specifying flor
#
# Wed May  4 15:59:30 JST 2016
# Golden Week
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe Flor::Scheduler do

    describe '#stop' do

      it 'stops' do

        expect(@unit.running?).to eq(true)
        expect(@unit.stopped?).to eq(false)

        @unit.stop

        expect(@unit.running?).to eq(false)
        expect(@unit.stopped?).to eq(true)
      end
    end

    describe '#launch' do

      it 'stores launch messages' do

        @unit.stop

        flon = %{
          sequence
            define sum a, b
              +
                a
                b
            sum 1 2
        }

        exid = @unit.launch(flon)

        expect(
          exid
        ).to match(
          /\Atest-u-#{Time.now.year}\d{4}\.\d{4}\.[a-z]+\z/
        )

        ms = @unit.storage.db[:flon_messages].all
        m = ms.first

        expect(ms.size).to eq(1)
        expect(m[:exid]).to eq(exid)
        expect(m[:point]).to eq('execute')
        expect(Flor::Storage.from_blob(m[:content])['exid']).to eq(exid)

        expect(@unit.storage.db[:flon_executions].count).to eq(0)
      end

      describe '(flow)' do

        it 'launches' do

          flon = %{
            sequence
              define sum a, b
                +
                  a
                  b
              sum 1 2
          }

          msg = @unit.launch(flon, wait: true)

          expect(msg.class).to eq(Hash)
          expect(msg['point']).to eq('terminated')
          expect(msg['payload']['ret']).to eq(3)

          es = @unit.storage.db[:flon_executions].all
          e = es.first

          expect(es.size).to eq(1)
          expect(e[:exid]).to eq(msg['exid'])

          sleep 0.3

          d = @unit.executions.first.data

          expect(
            d['counters']
          ).to eq({
            'funs' => 1, 'msgs' => 29, 'omsgs' => 0, 'subs' => 1, 'runs' => 1
          })
        end

        it 'rejects unparseable flows' do

          expect {
            @unit.launch('sequence,,,,')
          }.to raise_error(
            ArgumentError, 'flon parse failure'
          )
        end
      end

      describe '(path)' do

        it 'looks up a flow' do

          msg, _ = @unit.launch('com.acme.flow0', nolaunch: true)

          expect(msg['point']).to eq('execute')
          expect(msg['exid']).to match(/\Acom\.acme-u-2/)

          expect(
            msg['tree']
          ).to eq(
            [ 'sequence', [ [ 'alice', [], 2 ], [ 'bob', [], 3 ] ], 1 ]
          )
        end

        it 'fails if it cannot find the flow' do

          expect {
            @unit.launch('com.acme.flow-999')
          }.to raise_error(
            ArgumentError, 'flow not found in "com.acme.flow-999"'
          )
        end
      end

      describe '(flow, domain: d)' do

        it 'rejects invalid domain names' do

          expect {
            @unit.launch('', domain: 'blah-blah blah')
          }.to raise_error(
            ArgumentError, "invalid domain name \"blah-blah blah\""
          )
        end

        it 'looks up a flow' do

          msg, _ =
            @unit.launch('com.acme.flow0', domain: 'org.acme', nolaunch: true)

          expect(msg['point']).to eq('execute')
          expect(msg['exid']).to match(/\Aorg\.acme-u-2/)

          expect(
            msg['tree']
          ).to eq(
            [ 'sequence', [ [ 'alice', [], 2 ], [ 'bob', [], 3 ] ], 1 ]
          )
        end
      end

      describe '(path, domain: d)' do

it 'looks up from path but launches in d'
#        it 'looks up from path but launches in d' do
#
#          msg, _ = @unit.launch('com.acme.flow0', domain: 'x.y', nolaunch: true)
#
#          expect(msg['point']).to eq('execute')
#          expect(msg['exid']).to match(/\Ax\.y-u-2/)
#
#          expect(
#            msg['tree']
#          ).to eq(
#            [ 'sequence', [ [ 'alice', [], 2 ], [ 'bob', [], 3 ] ], 1 ]
#          )
#        end
      end
    end

    describe '#queue' do

      it 'lets queue cancel messages' do

        flon = %{
          sequence
            sequence
              stall _
        }

        exid = @unit.launch(flon)

        sleep 0.350

        r = @unit.queue(
          { 'point' => 'cancel', 'exid' => exid, 'nid' => '0_0' },
          wait: true)

        expect(r['point']).to eq('terminated')
      end
    end

    describe '#cancel' do

      it 'queues cancel messages' do

        flon = %{
          sequence
            sequence
              stall _
        }

        exid = @unit.launch(flon)

        sleep 0.350

        xd = @unit.executions[exid: exid].data

        expect(xd['nodes'].keys).to eq(%w[ 0 0_0 0_0_0 ])

        r = @unit.cancel(exid: exid, nid: '0_0', wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.1

        expect(
          @unit.executions.where(status: 'active').count
        ).to eq(0)
      end
    end
  end
end

