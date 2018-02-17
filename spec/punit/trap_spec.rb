
#
# specifying flor
#
# Fri May 20 14:29:17 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_trap'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'trap' do

    it 'flanks its parent node' do

      r = @unit.launch(
        %q{
          trap 'nada'
            def msg \ noret _
          stall _
        },
        wait: 'end')

      exid = r['exid']

      # check execution

      exe = @unit.executions[exid: exid]

      expect(exe).not_to eq(nil)
      expect(exe.failed?).to eq(false)

      # check nodes

      n_0 = exe.nodes['0']
      n_0_0 = exe.nodes['0_0']

      expect(n_0['status'].last['status']).to eq(nil) # open
      expect(n_0['cnodes']).to eq(%w[ 0_0 0_1 ]) # 0_0 is flanking

      expect(n_0_0['status'].last['status']).to eq(nil) # open
      expect(n_0_0['parent']).to eq('0')
      expect(n_0_0['noreply']).to eq(true) # since it's flanking

      # check trap record

      expect(@unit.traps.count).to eq(1)

      t = @unit.traps.first

#pp t.values.reject { |k, v| k == :content }
#pp t.data
      expect(t.exid).to eq(exid)
      expect(t.domain).to eq('test')
      expect(t.nid).to eq('0_0')
      expect(t.onid).to eq('0_0')
      expect(t.status).to eq('active')
      expect(t.data['message']['point']).to eq('execute')
      expect(t.data['message']['nid']).to eq('0_0_1')
      expect(t.data['message']['from']).to eq('0_0')
      expect(t.data['message']['tree'][0]).to eq('_apply')
    end

    it 'traps messages' do

      r = @unit.launch(
        %q{
          sequence
            trap 'terminated'
              def msg \ trace "terminated(f:$(msg.from))"
            trace "here($(nid))"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.350

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'here(0_1_0_0) terminated(f:0)'
      )

      ms = @unit.journal
      m0 = ms.find { |m| m['point'] == 'terminated' }
      m1 = ms.find { |m| m['point'] == 'trigger' }

      expect(m1['sm']).to eq(m0['m'])
    end

    it 'does not cancel its children' do

      r = @unit.launch(
        %q{
          trap point: 'left'
            def msg \ stall _
          sequence tag: 'x'
          sequence tag: 'y'
          sequence tag: 'z'
          stall _
        },
        wait: '0_4 receive; end')

      exid = r['exid']

      expect(
        @unit.journal.select { |m| m['point'] == 'trigger' }.count
      ).to eq(3)

      exe = @unit.executions[exid: r['exid']]

      expect(
        exe.nodes.keys
      ).to eq(%w[
        0 0_0 0_0_1-1 0_0_1_1-1 0_0_1-2 0_0_1_1-2 0_4 0_0_1-3 0_0_1_1-3
      ])

      @unit.cancel(exid: exid, nid: '0_0')

      @unit.wait(exid, 'end')

      exe = @unit.executions[exid: r['exid']]

      expect(exe.status).to eq('active')
      expect(exe.nodes['0_0']['status'].last['status']).to eq('ended')

      expect(
        exe.nodes.keys
      ).to eq(%w[
        0 0_0 0_0_1-1 0_0_1_1-1 0_0_1-2 0_0_1_1-2 0_4 0_0_1-3 0_0_1_1-3
      ])
    end

    it 'traps multiple times' do

      r = @unit.launch(
        %q{
          trap point: 'receive'
            def msg \ trace "$(msg.nid)<-$(msg.from)"
          sequence
            sequence
              trace '*'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.350

      expect(
        @unit.traces
          .each_with_index
          .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
      ).to eq(%w{
        0:*
        1:0_1_0_0_0<-0_1_0_0_0_0
        2:0_1_0_0<-0_1_0_0_0
        3:0_1_0<-0_1_0_0
        4:0_1<-0_1_0
        5:0<-0_1
        6:<-0
      }.collect(&:strip).join("\n"))
    end

    it 'traps in the current execution only by default' do

      exid0 = @unit.launch(%q{
        trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
        noret tag: 't0'
        trace "stalling_$(exid)"
        stall _
      })

      sleep 0.5

      r = @unit.launch(%{
        noret tag: 't0'
      }, wait: true)

      exid1 = r['exid']

      expect(r['point']).to eq('terminated')

      sleep 0.5

      expect(
        (
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }
        ).join("\n")
      ).to eq([
        "0:stalling_#{exid0}",
        "1:t0_#{exid0}"
      ].join("\n"))
    end

    it 'is bound at the parent level by default' do

      m = @unit.launch(%q{
        sequence
          trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
          stall _
      }, wait: '0_1 receive')

      expect(m['point']).to eq('receive')

      tra = @unit.traps.first

      expect(tra.nid).to eq('0_0')
      expect(tra.onid).to eq('0_0')
      expect(tra.bnid).to eq('0')
    end

    it 'has access to variables in the parent node' do

      r = @unit.launch(
        %q{
          set l []
          trap point: 'signal'
            def msg \ push l "$(msg.name)"
          signal 'hello'
          push l 'over'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ over hello ])
    end

    it 'is removed at the end of the execution' do

      expect(@unit.traps.count).to eq(0)

      r = @unit.launch(%q{
        sequence
          trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
      }, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.4

      exe = @unit.executions[exid: r['exid']]

#pp exe.data['nodes'].keys
      expect(exe.status).to eq('terminated')

#@unit.traps.each { |t| pp t.values }
      expect(@unit.traps.count).to eq(0)
    end

    it 'behaves as expected when at the root' do

      r = @unit.launch(%q{
        trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
      }, wait: '0 trap')

      expect(r['point']).to eq('trap')

      exid = r['exid']

      sleep 0.350

      exe = @unit.executions[exid: exid]

      expect(exe.status).to eq('active')
      expect(exe.nodes.keys).to eq(%w[ 0 ])

      expect(@unit.traps.count).to eq(1)

      t = @unit.traps.first

      expect(t.exid).to eq(exid)
      expect(t.nid).to eq('0')
      expect(t.onid).to eq('0')
      expect(t.bnid).to eq('0')
    end

    context 'count:' do

      it 'determines how many times a trap triggers at max' do

        r = @unit.launch(
          %q{
            sequence
              trap tag: 'b', count: 2
                def msg \ trace "A>$(nid)"
              sequence
                sleep 0.8
                noret tag: 'b'
                trace "B>$(nid)"
                noret tag: 'b'
                trace "B>$(nid)"
                noret tag: 'b'
                trace "B>$(nid)"
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 4 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:B>0_1_2_0_0
          1:A>0_0_2_1_0_0-1
          2:B>0_1_4_0_0
          3:A>0_0_2_1_0_0-2
          4:B>0_1_6_0_0
        }.collect(&:strip).join("\n"))
      end
    end

    context 'heap:' do

      it 'traps given procedures' do

        r = @unit.launch(
          %q{
            trap heap: 'sequence'
              def msg
                trace "$(msg.point)-$(msg.tree.0)-$(msg.nid)<-$(msg.from)"
            sequence
              noret _
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 2 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:execute-sequence-0_1<-0
          1:receive--0_1<-0_1_0
          2:receive--0<-0_1
        }.collect(&:strip).join("\n"))
      end
    end

    context 'heat:' do

      it 'traps given head of trees' do

        r = @unit.launch(
          %q{
            trap heat: 'fun0' \ def msg \ trace "t-$(msg.tree.0)-$(msg.nid)"
            define fun0 \ trace "c-fun0-$(nid)"
            sequence
              fun0 # not a call
              fun0 # not a call
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 1 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:t-fun0-0_2_0
          1:t-fun0-0_2_1
        }.collect(&:strip).join("\n"))
      end

      it 'traps given procedures' do

        r = @unit.launch(
          %q{
            trap heat: '_apply' \ def msg \ trace "t-heat-$(msg.nid)"
            define fun0 \ trace "c-fun0-$(nid)"
            sequence
              fun0 _
              fun0 _
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 7 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:c-fun0-0_1_1_0_0-1
          1:t-heat-0_1-1
          2:t-heat-0_1-1
          3:t-heat-0_1-1
          4:c-fun0-0_1_1_0_0-5
          5:t-heat-0_1-5
          6:t-heat-0_1-5
          7:t-heat-0_1-5
        }.collect(&:strip).join("\n"))
      end
    end

    context 'range: nid (default)' do

      it 'traps only subnids' do

        r = @unit.launch(%q{
          concurrence
            sequence
              trap tag: 't0' \ def msg \ trace "in-$(msg.nid)"
              stall tag: 't0'
            sequence
              sleep '1s' # give it time to process the trap
              noret tag: 't0'
        }, wait: '0_1_1 receive')

        expect(r['point']).to eq('receive')

        sleep 0.350

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:in-0_0_1
        }.collect(&:strip).join("\n"))
      end
    end

    context 'range: execution' do

      it 'traps in the same execution' do

        r = @unit.launch(%q{
          concurrence
            trap tag: 't1' range: 'execution'
              def msg \ trace "t1_$(msg.exid)"
            sequence
              sleep '1s'
              sequence tag: 't1'
                trace 'exe0'
                stall _
        }, wait: 'trigger')

        expect(r['point']).to eq('trigger')

        exid0 = r['exid']

        exid1 = @unit.launch(%{
          sequence tag: 't1'
            trace 'exe1'
        }, wait: true)

        sleep 0.350

        expect(
          @unit.traces.collect(&:text).join("\n")
        ).to eq([
          "exe0", "t1_#{exid0}", "exe1"
        ].join("\n"))
      end
    end

    context 'range: domain' do

      it 'traps the events in execution domain' do

        exid0 = @unit.launch(%q{
          trap tag: 't0' range: 'domain' \ def msg \ trace "t0_$(msg.exid)"
          trace "stalling_$(exid)"
          stall _
        }, domain: 'net.acme')

        sleep 0.5

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'org.acme', wait: true)
        exid1 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'net.acme', wait: true)
        exid2 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'net.acme.s0', wait: true)
        exid3 = r['exid']
        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count == 2 }

        expect(
          (
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }
          ).join("\n")
        ).to eq([
          "0:stalling_#{exid0}",
          "1:t0_#{exid2}"
        ].join("\n"))
      end
    end

    context 'range: subdomain' do

      it 'traps the events in range domain and its subdomains' do

        exid0 = @unit.launch(%q{
          trap tag: 't0' range: 'subdomain' \ def msg \ trace "t0_$(msg.exid)"
          trace "stalling_$(exid)"
          stall _
        }, domain: 'net.acme')

        sleep 0.5

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'org.acme', wait: true)
        exid1 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'net.acme', wait: true)
        exid2 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noret tag: 't0' }, domain: 'net.acme.s0', wait: true)
        exid3 = r['exid']
        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count == 3 }

        expect(
          (
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }
          ).join("\n")
        ).to eq([
          "0:stalling_#{exid0}",
          "1:t0_#{exid2}",
          "2:t0_#{exid3}"
        ].join("\n"))
      end
    end

    context 'tag:' do

      it 'traps tag entered' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap tag: 'x'
                def msg \ trace msg.point
              sequence tag: 'x'
                trace 'c'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 2 }

        expect(
          @unit.traces.collect(&:text).join(' ')
        ).to eq(
          'a c entered'
        )
      end
    end

    context 'consumed:' do

      # It's nice and all, but by the time the msg is run through the trap
      # it has already been consumed...

      it 'traps after the message consumption' do

        r = @unit.launch(
          %q{
            trace 'a'
            trap point: 'signal', consumed: true
              def msg \ trace "0con:m$(msg.m)sm$(msg.sm)"
            trap point: 'signal', consumed: true
              def msg \ trace "1con:m$(msg.m)sm$(msg.sm)"
            trap point: 'signal'
              def msg \ trace "0nocon:m$(msg.m)sm$(msg.sm)"
            signal 'S'
            trace 'b'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 4 }

        expect(
          @unit.traces.collect(&:text).join(' ')
        ).to eq(%{
          a b 0con:m58sm57 1con:m58sm57 0nocon:m58sm57
        }.strip)
      end
    end

    context 'point:' do

      it 'traps "signal"' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap point: 'signal'
                def msg \ trace "S"
              trace 'b'
              signal 'S'
              trace 'c'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 3 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a b c S
        ])
      end

      it 'traps "signal" and name:' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap point: 'signal', name: 's0'
                def msg \ trace "s0"
              trap point: 'signal', name: 's1'
                def msg \ trace "s1"
              signal 's0'
              signal 's1'
              signal 's2'
              trace 'b'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 3 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a s0 s1 b
        ])
      end

      it 'traps "signal" and its payload' do

        r = @unit.launch(
          %q{
            trap point: 'signal', name: 's0'
              def msg \ trace "s0:$(msg.payload.ret)"
            signal 's0'
              [ 1, 2, 3 ]
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 0 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          s0:[1,2,3]
        ])
      end
    end

    context 'signal:' do

      it "traps the 'signal' point with the given name" do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap signal: 'S0'
                def msg \ trace "S0"
              trace 'b'
              signal 'S0'
              trace 'c'
              signal 'S1'
              trace 'd'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 3 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a b c S0 d
        ])
      end

      it 'traps an array of signals' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap signal: [ 'S0' 'S1' ]
                def msg \ trace sig
              trace 'b'
              signal 'S0'
              trace 'c'
              signal 'S1'
              trace 'd'
              trace 'e'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 3 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a b c S0 d S1 e
        ])
      end

      it 'traps a signal by regex' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              #trap signal: [ /^S\d+$/, 'Sx' ]
              trap signal: /^S\d+$/
                def msg \ trace sig
              trace 'b'
              signal 'S0'
              trace 'c'
              signal 'S1'
              trace 'd'
              signal 'S2x'
              trace 'e'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 3 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a b c S0 d S1 e
        ])
      end
    end

    context 'payload:' do

      it 'uses the trap payload if "trap" (default)' do

        r = @unit.launch(
          %q{
            trap point: 'signal' name: 's0' payload: 'trap'
              def msg \ trace "s0:$(f.ret):$(msg.payload.ret)"
            signal 's0'
              [ 1, 2, 3 ]
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 0 }

        expect(@unit.traces.count).to eq(1)

        expect(
          @unit.traces.first.text
        ).to eq(%w[
          s0
          ["_func",{"nid":"0_0_3","tree":["def",[["_att",[["msg",[],3]],3],["trace",[["_att",[["_dqs","s0:$(f.ret):$(msg.payload.ret)",3]],3]],3]],3],"cnid":"0_0","fun":0},3]
          [1,2,3]
        ].join(':'))
      end

      it 'uses the event payload if "event"' do

        r = @unit.launch(
          %q{
            trap point: 'signal' name: 's0' payload: 'event'
              def msg
                trace "s0:$(f.ret):$(msg.payload.ret)"
                trace "s0:$(payload.ret)"
            signal 's0'
              [ 1, 2, 3 ]
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 0 }

        ts = @unit.traces.all

        expect(ts.size).to eq(2)

        expect(
          ts[0].text
        ).to eq(%{
          s0:[1,2,3]:[1,2,3]
        }.strip)

        expect(
          ts[1].text
        ).to eq(%{
          s0:["_func",{"nid":"0_0_3","tree":["def",[["_att",[["msg",[],3]],3],["trace",[["_att",[["_dqs","s0:$(f.ret):$(msg.payload.ret)",4]],4]],4],["trace",[["_att",[["_dqs","s0:$(payload.ret)",5]],5]],5]],3],"cnid":"0_0","fun":0},3]
        }.strip)
      end
    end

    context 'multiple criteria' do

      it 'traps messages matching all the criteria' do

        r = @unit.launch(
          %q{
            sequence
              trace 'a'
              trap tag: 'x', point: 'left'
                def msg \ trace "$(msg.point)-$(msg.nid)"
              sequence tag: 'x'
                trace 'c'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 2 }

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a c left-0_2
        ])
      end
    end

    context 'without function' do

      it 'blocks once' do

        r = @unit.launch(
          %q{
            concurrence
              trap tag: 'b'
              sequence
                sleep 0.8
                noret tag: 'b'
                noret tag: 'b'
                trace "B>$(nid)"
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        wait_until { @unit.traces.count > 0 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:B>0_1_3_0_0
        }.collect(&:strip).join("\n"))
      end
    end
  end
end

