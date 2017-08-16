
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
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

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

        exid = @unit.launch(
          %q{
            sequence
              define sum a, b
                +
                  a
                  b
              sum 1 2
          })

        expect(
          exid
        ).to match(
          /\Atest-u-#{Time.now.utc.year}\d{4}\.\d{4}\.[a-z]+\z/
        )

        ms = @unit.storage.db[:flor_messages].all
        m = ms.first

        expect(ms.size).to eq(1)
        expect(m[:exid]).to eq(exid)
        expect(m[:point]).to eq('execute')
        expect(Flor::Storage.from_blob(m[:content])['exid']).to eq(exid)

        expect(@unit.executions.count).to eq(0)
      end

      describe '(tree)' do

        it 'launches' do

          tree =
            Flor.parse(
              %q{
                sequence
                  define sum a, b
                    +
                      a
                      b
                  sum 1 1
              },
              "#{__FILE__}:#{__LINE__}")

          msg = @unit.launch(tree, wait: true)

          expect(msg.class).to eq(Hash)
          expect(msg['point']).to eq('terminated')
          expect(msg['payload']['ret']).to eq(2)

          wait_until { @unit.executions.count > 0 }

          es = @unit.executions.all
          e = es.first

          expect(es.size).to eq(1)
          expect(e[:exid]).to eq(msg['exid'])

          #sleep 0.3

          d = @unit.executions.first.data

          expect(
            d['counters']
          ).to eq({
            'funs' => 1, 'msgs' => 29, 'omsgs' => 0, 'subs' => 1, 'runs' => 1
          })
        end
      end

      describe '(flow)' do

        it 'launches' do

          r = @unit.launch(
            %q{
              sequence
                define sum a, b
                  +
                    a
                    b
                sum 1 2
            },
            wait: true)

          expect(r.class).to eq(Hash)
          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(3)

          wait_until { @unit.executions.count > 0 }

          es = @unit.executions.all
          e = es.first

          expect(es.size).to eq(1)
          expect(e[:exid]).to eq(r['exid'])

          wait_until { @unit.executions.first.data }

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
            #ArgumentError, 'flow parsing failed: "sequence,,,,"...'
            Flor::ParseError, 'syntax error at line 1 column 9'
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
            [
              'sequence',
              [ [ 'alice', [], 2 ], [ 'bob', [], 3 ] ],
              1,
              'envs/test/lib/flows/com.acme/flow0.flor'
            ]
          )
        end

        it 'fails if it cannot find the flow' do

          expect {
            @unit.launch('com.acme.flow-999')
          }.to raise_error(
            ArgumentError, 'flow not found in "com.acme.flow-999"'
          )
        end

        it 'fails if the flow is not parseable' do

          expect {
            @unit.launch('com.acme.flow99')
          }.to raise_error(
            #ArgumentError, /\Aflow parsing failed: /
            Flor::ParseError, 'syntax error at line 6 column 3'
          )
        end

        it 'sets the flow path in the launch tree' do

          r = @unit.launch('com.acme.flow1', wait: true)

          wait_until { @unit.executions.first }

          exe = @unit.executions.first.data

          expect(
            exe['nodes']['0']['tree'][3]
          ).to eq(
            'envs/test/lib/flows/com.acme/flow1.flor'
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

        it 'launches in domain d' do

          msg, _ =
            @unit.launch(
              'sequence \\ bob | charly',
              domain: 'org.acme', nolaunch: true)

          expect(msg['point']).to eq('execute')
          expect(msg['exid']).to match(/\Aorg\.acme-u-2/)

          expect(
            msg['tree']
          ).to eq(
            [ 'sequence', [ [ 'bob', [], 1 ], [ 'charly', [], 1 ] ], 1 ]
          )
        end
      end

      describe '(path, domain: d)' do

        it 'looks up from path but launches in d' do

          msg, _ = @unit.launch('com.acme.flow0', domain: 'x.y', nolaunch: true)

          expect(msg['point']).to eq('execute')
          expect(msg['exid']).to match(/\Ax\.y-u-2/)

          expect(
            msg['tree']
          ).to eq(
            [
              'sequence',
              [ [ 'alice', [], 2 ], [ 'bob', [], 3 ] ],
              1,
              'envs/test/lib/flows/com.acme/flow0.flor'
            ]
          )
        end
      end
    end

    describe '#queue' do

      it 'queues cancel messages' do

        r = @unit.launch(
          %q{
            sequence
              sequence
                stall _
          },
          wait: 'end')

        r = @unit.queue(
          { 'point' => 'cancel', 'exid' => r['exid'], 'nid' => '0_0' },
          wait: true)

        expect(r['point']).to eq('terminated')
      end
    end

    describe '#prepare_message (protected)' do

      it 'works for #cancel(exid: a, nid: b)' do

        msg, opts = @unit.send(:prepare_message,
          'cancel', [ { exid: 'a', nid: 'b' } ])

        expect(msg).to eqj(point: 'cancel', exid: 'a', nid: 'b')
        expect(opts).to eq({})

        msg, opts = @unit.send( :prepare_message,
          'cancel', [ { exid: 'a', nid: 'b', 'nada' => 'c' } ])

        expect(msg).to eqj(point: 'cancel', exid: 'a', nid: 'b')
        expect(opts).to eq(nada: 'c')
      end

      it 'works for #cancel(exid, nid)' do

        msg, opts = @unit.send(:prepare_message,
          'cancel', [ 'a', 'b' ])

        expect(msg).to eqj(point: 'cancel', exid: 'a', nid: 'b')
        expect(opts).to eq({})

        msg, opts = @unit.send(:prepare_message,
          'cancel', [ 'a', 'b', { c: 0 }, { c: 1 } ])

        expect(msg).to eqj(point: 'cancel', exid: 'a', nid: 'b')
        expect(opts).to eq(c: 1)
      end

      it 'works for #cancel(exid)' do

        msg, opts = @unit.send(:prepare_message,
          'cancel', [ 'a' ])

        expect(msg).to eqj(point: 'cancel', exid: 'a')
        expect(opts).to eq({})

        msg, opts = @unit.send(:prepare_message,
          'cancel', [ 'a', { c: 0 }, { d: 1 } ])

        #expect(msg).to eqj(point: 'cancel', exid: 'a', nid: 'b')
        expect(msg).to eqj(point: 'cancel', exid: 'a')
        expect(opts).to eq(c: 0, d: 1)
      end
    end

    describe '#cancel' do

      it 'queues cancel messages' do

        r = @unit.launch(
          %q{
            sequence
              sequence
                stall _
          },
          wait: 'end')

        exid = r['exid']

        wait_until { @unit.executions[exid: exid] }

        xd = @unit.executions[exid: exid].data

        expect(xd['nodes'].keys).to eq(%w[ 0 0_0 0_0_0 ])

        r = @unit.cancel(exid: exid, nid: '0_0', wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.executions.where(status: 'active').count < 1 }
      end

      it 'queues cancel messages (2)' do

        r = @unit.launch(
          %q{
            sequence
              sequence
                stall _
          },
          wait: 'end')

        exid = r['exid']

        wait_until { @unit.executions[exid: exid] }

        xd = @unit.executions[exid: exid].data

        expect(xd['nodes'].keys).to eq(%w[ 0 0_0 0_0_0 ])

        r = @unit.cancel(exid, '0_0', wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.executions.where(status: 'active').count < 1 }
      end
    end

    describe '#signal' do

      it 'queues signal messages' do

        r = @unit.launch(
          %q{
            on 'blue'
              trace 'blue'

            stall _
          },
          wait: '0_1 receive')

        expect(r['point']).to eq('receive')

        exid = r['exid']

        @unit.signal('blue', exid: exid)

        @unit.wait(exid, 'trigger; 0_0 receive')

        ts = @unit.traces.all
        t = ts.first

        expect(ts.size).to eq(1)
        expect(t.text).to eq('blue')
      end

      it 'emits an empty payload by default' do

        r = @unit.launch(
          %q{
            trap point: 'signal', name: 's0', payload: 'event'
              def msg; trace "s0:$(msg.payload.ret)"
            stall _
          },
          wait: '0_1 receive')

        expect(r['point']).to eq('receive')

        @unit.signal('s0', exid: r['exid'])

        wait_until { @unit.traces.count > 0 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          s0:
        ])
      end
    end

    context 'sch_msg_max_res_time' do

      it 'flags as "active" messages that have been reserved for too long' do

        @unit.instance_eval { @reload_after = 1 }
          # ensure we don't have to fait 1 minute before the next wake up

        dom = 'dom0'
        exid = Flor.generate_exid(dom, @unit.name)

        msg = Flor.make_launch_msg(
          exid, %{ sequence \ sequence \ sequence _ }, {})

        ctime = Flor.tstamp(Time.now - 15 * 60)
        mtime = Flor.tstamp(Time.now - 14 * 60)

        @unit.storage.db[:flor_messages].insert(
          domain: dom,
          exid: exid,
          point: 'execute',
          content: Flor::Storage.to_blob(msg),
          status: 'reserved',
          ctime: ctime,
          cunit: 'some-unit',
          mtime: mtime,
          munit: 'some-unit')

        @unit.instance_eval { @wake_up = true }
          # force wake_up

        r = @unit.wait(exid, 'terminated')

        expect(r['point']).to eq('terminated')
        expect(r['exid']).to eq(exid)
      end
    end
  end
end

