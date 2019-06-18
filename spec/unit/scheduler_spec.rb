
#
# specifying flor
#
# Wed May  4 15:59:30 JST 2016
# Golden Week
#
# Golden Week 2019 #dump and #load (Shinkansen from Shinyoko to Hiroshima)
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
            'funs' => 1, 'msgs' => 23, 'omsgs' => 0, 'subs' => 1, 'runs' => 1
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
            'funs' => 1, 'msgs' => 23, 'omsgs' => 0, 'subs' => 1, 'runs' => 1
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
            Flor::ParseError,
            'syntax error' +
            ' at line 6 column 3' +
            ' in envs/test/lib/flows/com.acme/flow99.flor'
          )
        end

        it 'sets the flow path in the launch tree' do

          @unit.launch('com.acme.flow1', wait: true)

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
              set f.x 'y'
              sequence
                stall _
          },
          wait: 'end')

        exid = r['exid']

        wait_until { @unit.executions[exid: exid] }

        xd = @unit.executions[exid: exid].data

        expect(xd['nodes'].keys).to eq(%w[ 0 0_1 0_1_0 ])

        r = @unit.cancel(exid: exid, nid: '0_1', wait: true)

        expect(r['payload']['x']).to eq('y')
        expect(r['point']).to eq('terminated')

        wait_until { @unit.executions.where(status: 'active').count < 1 }
      end

      it 'queues cancel messages (2)' do

        r = @unit.launch(
          %q{
            sequence
              set f.a 0
              stall _
          },
          wait: 'end')

        exid = r['exid']

        wait_until { @unit.executions[exid: exid] }

        xd = @unit.executions[exid: exid].data

        expect(xd['nodes'].keys).to eq(%w[ 0 0_1 ])

        r = @unit.cancel(exid, '0_1', wait: true)

        expect(r['payload']['a']).to eq(0)
        expect(r['point']).to eq('terminated')

        wait_until { @unit.executions.where(status: 'active').count < 1 }
      end

      it 'may cancel a whole execution' do

        exid = @unit.launch(%q{ stall _ }, payload: { 'a' => 0 })

        wait_until { @unit.executions[exid: exid] }

        r = @unit.cancel(exid, wait: true)

        expect(r['payload']['a']).to eq(0)
        expect(r['point']).to eq('terminated')

        wait_until { @unit.executions.where(status: 'active').count < 1 }
      end
    end

    describe '#kill' do

      it 'kills' do

        r = @unit.launch(
          %q{
            set l []
            sequence
              sequence on_cancel: (def msg \ push l 'oc')
                stall _
          },
          wait: 'end')

        exid = r['exid']

        @unit.kill(exid, '0_1')

        r = @unit.wait(exid)

        expect(r['point']).to eq('terminated')
        expect(r['vars']).to eq({ 'l' => [] })
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
              def msg \ trace "s0:$(msg.payload.ret)"
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

    describe '#last_queued_message_id' do

      it 'returns the id of the last queued message' do

        id = @unit.last_queued_message_id

        @unit.launch(%q{ stall _ })

        expect(@unit.last_queued_message_id).not_to eq(id)
      end
    end

    describe '#dump' do

      before :each do

        @exid0 = @unit.launch(%q{ stall _ })
        @exid1 = @unit.launch(%q{ stall timeout: '2h' })
        @exid2 = @unit.launch(%q{ on 'cancel' \ _ }, domain: 'org.acme.it')
        @exid3 = @unit.launch(%q{ hole 'take out cans' }, domain: 'org.acme')
        wait_until { @unit.executions.count == 4 }

        FileUtils.rm_f('tmp/dump.json')
      end

      after :each do

        FileUtils.rm_f('tmp/dump.json')
      end

      context '()' do

        it 'dumps all of the executions into a string' do

          s = @unit.dump
          h = JSON.load(s)

          expect(h['timestamp']).to be_a(String)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([ @exid1 ])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([ @exid2 ])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 4, 1, 1, 1 ])
        end
      end

      context '(exid: i)' do

        it 'dumps only a specific execution' do

          s = @unit.dump(exid: @exid3)
          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 1, 0, 0, 1 ])
        end
      end

      context '(exids: [ i0, ie1 ])' do

        it 'dumps only specific executions' do

          s = @unit.dump(exids: [ @exid1, @exid3, 'nada' ])
            # exid: or exids:

          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid1, @exid3 ].sort)
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([ @exid1 ])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 2, 1, 0, 1 ])
        end
      end

      context '(domain: d)' do

        it 'dumps only a specific domain' do

          s = @unit.dump(domain: 'org.acme')
          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid2, @exid3 ].sort)
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([ @exid2 ])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 2, 0, 1, 1 ])
        end
      end

      context '(domains: [ "org.acme.it", "test" ])' do

        it 'dumps only specific domains' do

          s = @unit.dump(domain: %w[ org.acme.it test ])
            # domain: or domains:

          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid0, @exid1, @exid2 ].sort)
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([ @exid1])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([ @exid2 ])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 3, 1, 1, 0 ])
        end
      end

      context '(strict_domain: d)' do

        it 'dumps only a specific domain (and not its subdomains)' do

          s = @unit.dump(sdomain: 'org.acme')
            # sdomain: or strict_domain:

          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 1, 0, 0, 1 ])
        end
      end

      context '(strict_domains: %w[ org.acme test ])' do

        it 'dumps only specific domains (and not their subdomains)' do

          s = @unit.dump(sdomain: %w[ org.acme test ])
            # sdomain: or strict_domain: or sdomains: or strict_domains:

          h = JSON.load(s)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid0, @exid1, @exid3 ].sort)
          expect(h['timers'].collect { |e| e['exid'] }
            ).to eq([ @exid1 ])
          expect(h['traps'].collect { |e| e['exid'] }
            ).to eq([])
          expect(h['pointers'].collect { |e| e['exid'] }
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 3, 1, 0, 1 ])
        end
      end

      context '(io)' do

        it 'dumps there (StringIO)' do

          o = StringIO.new
          @unit.dump(o)
          h = JSON.load(o.string)

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 4, 1, 1, 1 ])
        end

        it 'dumps there (File)' do

          File.open('tmp/dump.json', 'wb') { |f| @unit.dump(f) }
          h = JSON.load(File.read('tmp/dump.json'))

          expect(h['executions'].collect { |e| e['exid'] }.sort
            ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)

          expect(
            %w[ executions timers traps pointers ].collect { |k| h[k].count }
              ).to eq([ 4, 1, 1, 1 ])
        end
      end

      context '() { |h| ... }' do

        it 'passes the resulting Hash to its block' do

          s = @unit.dump { |h| h[:team] = 'Hiroshima Toyo Carp' }
          h = JSON.load(s)

          expect(h.keys.sort
            ).to eq(%w[ executions pointers team timers timestamp traps ])
          expect(h['team']
            ).to eq('Hiroshima Toyo Carp')
        end
      end
    end

    describe '#load' do

      before :each do

        @exid0 = @unit.launch(%q{ stall _ })
        @exid1 = @unit.launch(%q{ stall timeout: '2h' })
        @exid2 = @unit.launch(%q{ on 'cancel' \ _ }, domain: 'org.acme.it')
        @exid3 = @unit.launch(%q{ hole 'take out cans' }, domain: 'org.acme')
        wait_until { @unit.executions.count == 4 }

        File.open('tmp/dump.json', 'wb') { |f| @unit.dump(f) }

        @unit.storage.delete_tables
      end

      after :each do

        FileUtils.rm_f('tmp/dump.json')
      end

      context '(string)' do

        it 'fails if the string is not a valid dump' do

          h = JSON.load(File.read('tmp/dump.json'))
          h.delete('executions')
          s = JSON.dump(h)

          expect {
            @unit.load(s)
          }.to raise_error(
            Flor::FlorError, 'missing keys ["executions"]'
          )
        end

        it 'loads' do

          i = @unit.load(File.read('tmp/dump.json'))

          expect(i).to eq({
            executions: 4, timers: 1, traps: 1, pointers: 1, total: 7 })

          expect(
            @unit.storage.db[:flor_executions].map(:exid).sort
              ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)
        end

        it "doesn't mind extra info" do

          h = JSON.load(File.read('tmp/dump.json'))
          h['tasks'] = (1..100).collect { |i| { task_id: i } }
          s = JSON.dump(h)

          i = @unit.load(s)

          expect(i).to eq({
            executions: 4, timers: 1, traps: 1, pointers: 1, total: 7 })

          expect(
            @unit.storage.db[:flor_executions].map(:exid).sort
              ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)
        end
      end

      context '(io)' do

        it 'loads' do

          f = File.open('tmp/dump.json')
          i = @unit.load(f)

          expect(i).to eq({
            executions: 4, timers: 1, traps: 1, pointers: 1, total: 7 })

          expect(
            @unit.storage.db[:flor_executions].map(:exid).sort
          ).to eq(
            [ @exid0, @exid1, @exid2, @exid3 ].sort
          )

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 4, 1, 1, 1 ])

          f.rewind
          h = JSON.load(f.read)

          expect(h.keys).to include('executions')
        end
      end

      context '(io, close: true)' do

        it 'loads from and then closes the io' do

          f = File.open('tmp/dump.json')
          i = @unit.load(f, close: true)

          expect(i).to eq({
            executions: 4, timers: 1, traps: 1, pointers: 1, total: 7 })

          expect(
            @unit.storage.db[:flor_executions].map(:exid).sort
          ).to eq(
            [ @exid0, @exid1, @exid2, @exid3 ].sort
          )

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 4, 1, 1, 1 ])

          expect { f.rewind }.to raise_error(IOError, 'closed stream')
        end
      end

      context '(s, exid: "xxx")' do

        it 'loads only a certain execution' do

          i = @unit.load(File.read('tmp/dump.json'), exid: @exid1)

          expect(i).to eq({
            executions: 1, timers: 1, traps: 0, pointers: 0, total: 2 })

          expect( @unit.storage.db[:flor_executions].map(:exid)
            ).to eq([ @exid1 ])

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 1, 1, 0, 0 ])
        end
      end

      context '(s, exids: [ a, b ])' do

        it 'loads only a certain execution' do

          i = @unit.load(File.read('tmp/dump.json'), exid: [ @exid1, @exid3 ])
            # exid: or exids:

          expect(i).to eq({
            executions: 2, timers: 1, traps: 0, pointers: 1, total: 4 })

          expect( @unit.storage.db[:flor_executions].map(:exid).sort
            ).to eq([ @exid1, @exid3 ].sort)

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 2, 1, 0, 1 ])
        end
      end

      context '(s, domain: "org.acme")' do

        it 'loads only the executions in a domain and its subdomains' do

          i = @unit.load(File.read('tmp/dump.json'), domain: 'org.acme')

          expect(i).to eq({
            executions: 2, timers: 0, traps: 1, pointers: 1, total: 4 })

          expect( @unit.storage.db[:flor_executions].map(:exid).sort
            ).to eq([ @exid2, @exid3 ].sort)

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 2, 0, 1, 1 ])
        end
      end

      context '(s, domains: [ "org.acme.it", "test" ])' do

        it 'loads only the executions in a domain and its subdomains' do

          i = @unit.load(
            File.read('tmp/dump.json'),
            domains: %w[ org.acme.it test ])
              # domain: or domains:

          expect(i).to eq({
            executions: 3, timers: 1, traps: 1, pointers: 0, total: 5 })

          expect( @unit.storage.db[:flor_executions].map(:exid).sort
            ).to eq([ @exid0, @exid1, @exid2 ].sort)

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 3, 1, 1, 0 ])
        end
      end

      context '(s, strict_domain: "org.acme")' do

        it 'loads only the executions in a domain and not its subdomains' do

          i = @unit.load(File.read('tmp/dump.json'), sdomain: 'org.acme')

          expect(i).to eq({
            executions: 1, timers: 0, traps: 0, pointers: 1, total: 2 })

          expect( @unit.storage.db[:flor_executions].map(:exid)
            ).to eq([ @exid3 ])

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 1, 0, 0, 1 ])
        end
      end

      context '(s, strict_domains: [ "org.acme", "test" ])' do

        it 'loads only the executions in a domain and not its subdomains' do

          i = @unit.load(
            File.read('tmp/dump.json'),
            sdomains: %w[ org.acme test ])
              # sdomain: or sdomains: or strict_domain: or strict_domains:

          expect(i).to eq({
            executions: 3, timers: 1, traps: 0, pointers: 1, total: 5 })

          expect( @unit.storage.db[:flor_executions].map(:exid).sort
            ).to eq([ @exid0, @exid1, @exid3 ].sort)

          expect(
            %w[ executions timers traps pointers ]
              .collect { |k| @unit.storage.db["flor_#{k}".to_sym].count }
          ).to eq([ 3, 1, 0, 1 ])
        end
      end

      context '(s) { |h| ... }' do

        it 'loads and yields to the block' do

          h = JSON.load(File.read('tmp/dump.json'))
          h['tasks'] = (1..100).collect { |i| { task_id: i } }
          s = JSON.dump(h)

          tc = nil

          i = @unit.load(s) { |hh|
            tc = hh['tasks'].collect { |e| e['task_id'] } }

          expect(i).to eq({
            executions: 4, timers: 1, traps: 1, pointers: 1, total: 7 })

          expect(
            @unit.storage.db[:flor_executions].map(:exid).sort
              ).to eq([ @exid0, @exid1, @exid2, @exid3 ].sort)

          expect(tc).to eq((1..100).to_a)
        end
      end
    end
  end
end

