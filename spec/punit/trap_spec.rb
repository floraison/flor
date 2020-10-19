
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

      expect(n_0_0).to have_key('replyto') # since it's flanking
      expect(n_0_0['replyto']).to eq(nil) # since it's flanking

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
            trace "here($(node.nid))"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      wait_until { @unit.traces.count > 1 }

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'here(0_1_0_0_1_0_0) terminated(f:0)'
      )

      ms = @unit.journal
      m0 = ms.find { |m| m['point'] == 'terminated' }
      m1 = ms.find { |m| m['point'] == 'trigger' }

      expect(m1['sm']).to eq(m0['m'])

      expect(
        @unit.journal
          .collect { |m|
            cs = (m['cause'] || [])
              .collect { |c| [ c['cause'], c['m'], c['nid'] ].join(':') }
            cs = cs.any? ? " <-" + cs.join('<-') : ''
            "#{m['point']}:#{m['nid']}#{cs}" }
          .join("\n")
      ).to eq(%{
        execute:0
        execute:0_0
        execute:0_0_0
        execute:0_0_0_0
        receive:0_0_0
        receive:0_0
        execute:0_0_1
        receive:0_0
        trap:0_0
        receive:0
        execute:0_1
        execute:0_1_0
        execute:0_1_0_0
        execute:0_1_0_0_0
        receive:0_1_0_0
        execute:0_1_0_0_1
        execute:0_1_0_0_1_0
        execute:0_1_0_0_1_0_0
        execute:0_1_0_0_1_0_0_0
        receive:0_1_0_0_1_0_0
        execute:0_1_0_0_1_0_0_1
        receive:0_1_0_0_1_0_0
        receive:0_1_0_0_1_0
        receive:0_1_0_0_1
        receive:0_1_0_0
        execute:0_1_0_0_2
        receive:0_1_0_0
        receive:0_1_0
        receive:0_1
        receive:0
        receive:
        cancel:0_0 <-cancel:32:0_0
        receive: <-cancel:32:0_0
        ceased: <-cancel:32:0_0
        terminated:
        trigger:0_0 <-trigger:36:0_0
        execute:0_0_1-1 <-trigger:36:0_0
        execute:0_0_1_1-1 <-trigger:36:0_0
        execute:0_0_1_1_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_0-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_1-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_1_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_1_0_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_1_0_0_0-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0_1_0_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_1_0_0_1-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0_1_0_0-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0_1_0-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0_1-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0-1 <-trigger:36:0_0
        execute:0_0_1_1_0_0_2-1 <-trigger:36:0_0
        receive:0_0_1_1_0_0-1 <-trigger:36:0_0
        receive:0_0_1_1_0-1 <-trigger:36:0_0
        receive:0_0_1_1-1 <-trigger:36:0_0
        receive:0_0_1-1 <-trigger:36:0_0
        receive:0_0 <-trigger:36:0_0
        end:
      }.ftrim)
    end

    it 'traps messages (one-liner)' do

      r = @unit.launch(
        %q{
          sequence
            trap 'terminated' (def msg \ trace "terminated(f:$(msg.from))")
            trace "here($(node.nid))"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      wait_until { @unit.traces.count > 1 }

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'here(0_1_0_0_1_0_0) terminated(f:0)'
      )

      ms = @unit.journal
      m0 = ms.find { |m| m['point'] == 'terminated' }
      m1 = ms.find { |m| m['point'] == 'trigger' }

      expect(m1['sm']).to eq(m0['m'])
    end

    it 'traps multiple times' do

      #@unit.hooker.add('spec_hook') do |m|
      #  nid = m['nid'] || '_'
      #  if m['consumed'] && nid.index(/-/).nil?
      #    #p m.keys
      #    p m.select { |k, v|
      #      %w[ point nid from type m sm flavour ].include?(k) }
      #  end
      #end

      r = @unit.launch(
        %q{
          trap point: 'receive'
            def msg \ trace "$(msg.nid)<-$(msg.from)"
          sequence
            sequence
              trace '*'
        },
        wait: true)

      expect(r).to have_terminated_as_point

      wait_until { @unit.traces.count > 6 }

      expect(
        @unit.traces
          .each_with_index
          .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
      ).to eq(%{
        0:*
        1:0_1_0_0_0<-0_1_0_0_0_0
        2:0_1_0_0<-0_1_0_0_0
        3:0_1_0<-0_1_0_0
        4:0_1<-0_1_0
        5:0<-0_1
        6:<-0
      }.ftrim)
    end

    it 'traps in the current execution only by default' do

      exid0 = @unit.launch(%q{
        trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
        noret tag: 't0'
        trace "stalling_$(exe.exid)"
        stall _
      })

      sleep 0.5

      r = @unit.launch(%{
        noret tag: 't0'
      }, wait: true)
      #exid1 = r['exid']

      expect(r).to have_terminated_as_point

      wait_until { @unit.traces.count > 1 }

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

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq(%w[ over hello ])
    end

    it 'is removed at the end of the execution' do

      expect(@unit.traps.count).to eq(0)

      r = @unit.launch(%q{
        sequence
          trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
      }, wait: true)

      expect(r).to have_terminated_as_point

      wait_until {
        exe = @unit.executions[exid: r['exid']]
        exe && exe.status == 'terminated'
      }

      expect(@unit.traps.count).to eq(0)
    end

    it 'behaves as expected when at the root' do

      r = @unit.launch(%q{
        trap tag: 't0' \ def msg \ trace "t0_$(msg.exid)"
      }, wait: '0 trap')

      expect(r['point']).to eq('trap')

      exid = r['exid']

      exe = wait_until { @unit.executions[exid: exid] }

      expect(exe.status).to eq('active')
      expect(exe.nodes.keys).to eq(%w[ 0 ])

      expect(@unit.traps.count).to eq(1)

      t = @unit.traps.first

      expect(t.exid).to eq(exid)
      expect(t.nid).to eq('0')
      expect(t.onid).to eq('0')
      expect(t.bnid).to eq('0')
    end

    context 'attributes' do

      describe 'count:' do

        it 'determines how many times a trap triggers at max' do

          r = @unit.launch(
            %q{
              sequence
                trap tag: 'b', count: 2
                  def msg \ trace "A>$(node.nid)"
                sequence
                  sleep 0.8
                  noret tag: 'b'
                  trace "B>$(node.nid)"
                  noret tag: 'b'
                  trace "B>$(node.nid)"
                  noret tag: 'b'
                  trace "B>$(node.nid)"
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 4 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:B>0_1_2_0_0_1_0_0
            1:A>0_0_2_1_0_0_1_0_0-1
            2:B>0_1_4_0_0_1_0_0
            3:A>0_0_2_1_0_0_1_0_0-2
            4:B>0_1_6_0_0_1_0_0
          }.ftrim)
        end
      end

      describe 'heap:' do

        it 'traps given procedures' do

          r = @unit.launch(
            %q{
              trap heap: 'sequence'
                def msg
                  trace "$(msg.point)-$(msg.tree.0)-$(msg.nid)<-$(msg.from)"
              sequence
                noret _
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count >= 2 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:execute-sequence-0_1<-0
            1:receive--0_1<-0_1_0
            2:receive--0<-0_1
          }.ftrim)
        end

        it 'is OK with $(dollar) failing' do

          r = @unit.launch(
            %q{
              trap heap: 'sequence'
                def msg
                  trace "$(msg.nid):$(msg.tree.0)"
              sequence
                noret _
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count >= 2 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:0_1:sequence
            1:0_1:
            2:0:
          }.ftrim)
        end

        it 'traps multiple given procedures' do

          r = @unit.launch(
            %q{
              trap heap: [ 'sequence' 'concurrence' ]
                def msg
                  trace "$(msg.point)-$(msg.tree.0)-$(msg.nid)<-$(msg.from)"
              concurrence
                sequence
                  noret _
                sequence
                  noret _
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:execute-concurrence-0_1<-0
            1:execute-sequence-0_1_0<-0_1
            2:execute-sequence-0_1_1<-0_1
            3:receive--0_1_0<-0_1_0_0
            4:receive--0_1_1<-0_1_1_0
            5:receive--0_1<-0_1_0
            6:receive--0_1<-0_1_1
            7:receive--0<-0_1
          }.ftrim)
        end

        it 'traps a procedure and a point' do

          r = @unit.launch(
            %q{
              trap heap: [ 'sequence' 'concurrence' ] point: 'receive'
                def msg
                  trace "$(msg.point)-$(msg.tree.0)-$(msg.nid)<-$(msg.from)"
              concurrence
                sequence
                  noret _
                sequence
                  noret _
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:receive--0_1_0<-0_1_0_0
            1:receive--0_1_1<-0_1_1_0
            2:receive--0_1<-0_1_0
            3:receive--0_1<-0_1_1
            4:receive--0<-0_1
          }.ftrim)
        end

        #it 'traps a heap regex'
          # no, this is not necessary, "heat", on the other side, is
          # better suited for regexes
      end

      describe 'heat:' do

        it 'traps given head of trees' do

          r = @unit.launch(
            %q{
              trap heat: 'fun0' \ def msg \ trace "t-$(msg.tree.0)-$(msg.nid)"
              define fun0 \ trace "c-fun0-$(node.nid)"
              sequence
                fun0 # not a call
                fun0 # not a call
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 1 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:t-fun0-0_2_0
            1:t-fun0-0_2_1
          }.ftrim)
        end

        it 'traps given functions' do

          r = @unit.launch(
            %q{
              trap heat: '_apply' \ def msg \ trace "t-heat-$(msg.nid)"
              define fun0 \ trace "c-fun0-$(node.nid)"
              sequence
                fun0 _
                fun0 _
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count >= 6 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:c-fun0-0_1_1_0_0_1_0_0-1
            1:t-heat-0_1-1
            2:t-heat-0_1-1
            3:c-fun0-0_1_1_0_0_1_0_0-4
            4:t-heat-0_1-4
            5:t-heat-0_1-4
          }.ftrim)
        end

        it 'traps multiple heat:' do

          r = @unit.launch(
            %q{
              trap heat: [ 'fun0' 'fun1' ]
                def msg \ trace "t-$(msg.tree.0)-$(msg.nid)"
              define fun0 \ trace "c-fun0-$(node.nid)"
              define fun1 \ trace "c-fun1-$(node.nid)"
              sequence
                fun0 _
                fun1 _
                fun0
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 1 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:c-fun0-0_1_1_0_0_1_0_0-2
            1:t-fun0-0_3_0
            2:t--0_3_0
            3:c-fun1-0_2_1_0_0_1_0_0-6
            4:t-fun1-0_3_1
            5:t--0_3_0
            6:t--0_3_1
            7:t-fun0-0_3_2
            8:t--0_3_1
          }.ftrim)
        end

        it 'traps a heat regex' do

          r = @unit.launch(
            %q{
              trap heat: [ /^fun\d+$/ 'funx' ]
                def msg \ trace "t-$(msg.point)-$(msg.tree.0)-$(msg.nid)"
              define fun0 \ trace "c-fun0-$(node.nid)"
              define fun1 \ trace "c-fun1-$(node.nid)"
              define funx \ trace "c-funx-$(node.nid)"
              sequence
                fun0 _
                fun1 _
                fun0
                funx _
            },
            wait: 'terminated')

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count >= 1 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:c-fun0-0_1_1_0_0_1_0_0-2
            1:c-fun1-0_2_1_0_0_1_0_0-6
            2:t-execute-fun0-0_4_0
            3:t-receive--0_4_0
            4:t-execute-fun1-0_4_1
            5:t-receive--0_4_0
            6:c-funx-0_3_1_0_0_1_0_0-11
            7:t-receive--0_4_1
            8:t-execute-fun0-0_4_2
            9:t-receive--0_4_1
            10:t-execute-funx-0_4_3
            11:t-receive--0_4_3
            12:t-receive--0_4_3
          }.ftrim)
        end

        it 'traps a tree head and a point' do

          r = @unit.launch(
            %q{
              trap heat: [ /^fun\d+$/ 'funx' ] point: 'execute'
                def msg \ trace "t-$(msg.point)-$(msg.tree.0)-$(msg.nid)"
              define fun0 \ trace "c-fun0-$(node.nid)"
              define fun1 \ trace "c-fun1-$(node.nid)"
              define funx \ trace "c-funx-$(node.nid)"
              sequence
                fun0 _
                fun1 _
                fun0
                funx _
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 1 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%{
            0:c-fun0-0_1_1_0_0_1_0_0-2
            1:c-fun1-0_2_1_0_0_1_0_0-4
            2:t-execute-fun0-0_4_0
            3:t-execute-fun1-0_4_1
            4:c-funx-0_3_1_0_0_1_0_0-7
            5:t-execute-fun0-0_4_2
            6:t-execute-funx-0_4_3
          }.ftrim)
        end
      end

      describe 'range: subnid (default)' do

        it 'traps only subnids' do

          r = @unit.launch(%q{
            concurrence
              sequence
                trap tag: 't0' #range: 'subnid'
                  def msg \ trace "in-$(msg.nid)"
                stall tag: 't0' ### gets trapped
              sequence
                sleep '1s' # give it time to process the trap
                noret tag: 't0' ### doesn't get trapped
          }, wait: '0_1_1 receive')

          expect(r['point']).to eq('receive')

          wait_until { @unit.traces.count > 0 }

          expect(
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
          ).to eq(%w{
            0:in-0_0_1
          }.collect(&:strip).join("\n"))
            #
            # where 1:in-0_1_1 is not trapped
        end
      end

      describe 'range: execution' do

        it 'traps in the same execution' do

          r = @unit.launch(%q{
            concurrence
              sequence # <--- trap is bound here
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

          @unit.launch(
            %{
              sequence tag: 't1'
                trace 'exe1'
            }, wait: true)

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces.collect(&:text).join("\n")
          ).to eq([
            'exe0', "t1_#{exid0}", 'exe1'
          ].join("\n"))
        end
      end

      describe 'range: domain' do

        it 'traps the events in execution domain' do

          # 0
          exid0 = @unit.launch(%q{
            trap tag: 't0' range: 'domain' \ def msg \ trace "t0_$(msg.exid)"
            trace "stalling_$(exe.exid)"
            stall _
          }, domain: 'net.acme')

          wait_until { @unit.traps.count == 1 }

          # 1
          r = @unit.launch("noret tag: 't0'", domain: 'org.acme', wait: true)
          #exid1 = r['exid']
          expect(r).to have_terminated_as_point
            # completely different domain, not trapped

          # 2
          r = @unit.launch("noret tag: 't0'", domain: 'net.acme', wait: true)
          exid2 = r['exid']
          expect(r).to have_terminated_as_point
            # same domain, trapped

          # 3
          r = @unit.launch("noret tag: 't0'", domain: 'net.acme.s0', wait: true)
          #exid3 = r['exid']
          expect(r).to have_terminated_as_point
            # subdomain, not trapped

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

      describe 'range: subdomain' do

        it 'traps the events in range domain and its subdomains' do

          # 0
          exid0 = @unit.launch(%q{
            trap tag: 't0' range: 'subdomain' \ def msg \ trace "t0_$(msg.exid)"
            trace "stalling_$(exe.exid)"
            stall _
          }, domain: 'net.acme')

          wait_until { @unit.traps.count == 1 }

          # 1
          r = @unit.launch("noret tag: 't0'", domain: 'org.acme', wait: true)
          #exid1 = r['exid']
          expect(r).to have_terminated_as_point
            # completely different domain, not trapped

          # 2
          r = @unit.launch("noret tag: 't0'", domain: 'net.acme', wait: true)
          exid2 = r['exid']
          expect(r).to have_terminated_as_point
            # same domain, trapped

          # 3
          r = @unit.launch("noret tag: 't0'", domain: 'net.acme.s0', wait: true)
          exid3 = r['exid']
          expect(r).to have_terminated_as_point
            # subdomain of net.acme, trapped

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

      describe 'tag:' do

        it 'traps tag entered by default' do

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

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces.collect(&:text).join(' ')
          ).to eq(
            'a c entered'
          )
        end

        it 'traps tag left' do

          r = @unit.launch(
            %q{
              sequence
                trace 'a'
                trap tag: 'x' point: 'left'
                #trap tag: 'x' point: [ 'entered' 'left' ]
                  def msg \ trace "$(msg.tags.-1)-$(msg.point)"
                sequence tag: 'x'
                  trace 'x'
                sequence tag: 'y'
                  trace 'y'
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces.collect(&:text).join(' ')
          ).to eq(
            'a x y x-left'
          )
        end

        it 'traps multiple tags' do

          r = @unit.launch(
            %q{
              sequence
                trace 'in'
                trap tags: [ 'x', 'y' ]
                  def msg \ trace "$(msg.tags.-1)-$(msg.point)"
                sequence tag: 'x'
                  trace 'a'
                sequence tag: 'y'
                  trace 'b'
                sequence tag: 'z'
                  trace 'c'
                trace 'out'
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            in a b x-entered c out y-entered
          ])
        end

        it 'traps tags by regex' do

          r = @unit.launch(
            %q{
              sequence
                trace 'in'
                trap tags: r/^x-/
                  def msg \ trace "$(msg.tags.-1)-$(msg.point)"
                sequence tag: 'x-0' \ trace 'a'
                sequence tag: 'y' \ trace 'b'
                sequence tag: 'x-1' \ trace 'c'
                trace 'out'
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 2 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            in a b x-0-entered c out x-1-entered
          ])
        end
      end

      describe 'consumed:' do

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

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 4 }

          expect(
            @unit.traces.collect(&:text).join(' ')
          ).to eq(%{
            a b 0con:m58sm57 1con:m58sm57 0nocon:m58sm57
          }.strip)
        end
      end

      describe 'point:' do

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

          expect(r).to have_terminated_as_point

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

          expect(r).to have_terminated_as_point

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

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 0 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            s0:[1,2,3]
          ])
        end

        it 'traps multiple points: (array)' do

          r = @unit.launch(
            %q{
              trap point: [ 'left', 'entered' ]
                def msg \ trace "$(msg.nid)-$(msg.point)"
              sequence tag: 'x'
                0
              sequence tag: 'y'
                1
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 0 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            0_1-entered 0_1-left 0_2-entered 0_2-left
          ])
        end

        it 'traps multiple points: (string)' do

          r = @unit.launch(
            %q{
              trap point: 'left, entered'
                def msg \ trace "$(msg.nid)-$(msg.point)"
              sequence tag: 'x'
                0
              sequence tag: 'y'
                1
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 0 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            0_1-entered 0_1-left 0_2-entered 0_2-left
          ])
        end
      end

      describe 'signal:' do

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

          expect(r).to have_terminated_as_point

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

          expect(r).to have_terminated_as_point

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

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 3 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            a b c S0 d S1 e
          ])
        end
      end

      describe 'payload:' do

        it 'uses the trap payload if "trap" (default)' do

          r = @unit.launch(
            %q{
              trap point: 'signal' name: 's0' payload: 'trap'
                def msg \ trace "s0:$(f.ret):$(msg.payload.ret)"
              signal 's0'
                [ 1, 2, 3 ]
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 0 }

          expect(@unit.traces.count).to eq(1)

          expect(
            @unit.traces.first.text
          ).to eq(%w[
            s0
            ["_func",{"nid":"0_0_3","tree":["def",[["_att",[["msg",[],3]],3],["trace",[["_att",[["_dqs",[["_sqs","s0:",3],["_dol",[["_dmute",[["_ref",[["_sqs","f",3],["_sqs","ret",3]],3]],3]],3],["_sqs",":",3],["_dol",[["_dmute",[["_ref",[["_sqs","msg",3],["_sqs","payload",3],["_sqs","ret",3]],3]],3]],3]],3]],3]],3]],3],"cnid":"0_0","fun":0},3]
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

          expect(r).to have_terminated_as_point

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
            s0:["_func",{"nid":"0_0_3","tree":["def",[["_att",[["msg",[],3]],3],["trace",[["_att",[["_dqs",[["_sqs","s0:",4],["_dol",[["_dmute",[["_ref",[["_sqs","f",4],["_sqs","ret",4]],4]],4]],4],["_sqs",":",4],["_dol",[["_dmute",[["_ref",[["_sqs","msg",4],["_sqs","payload",4],["_sqs","ret",4]],4]],4]],4]],4]],4]],4],["trace",[["_att",[["_dqs",[["_sqs","s0:",5],["_dol",[["_dmute",[["_ref",[["_sqs","payload",5],["_sqs","ret",5]],5]],5]],5]],5]],5]],5]],3],"cnid":"0_0","fun":0},3]
          }.strip)
        end

        it 'uses the event payload if {object}"' do

          r = @unit.launch(
            %q{
              trap point: 'signal' name: 's0' payload: { trap: 'trap1' }
                def msg
                  trace "s0:$(f.trap)"
              signal 's0'
                [ 1, 2, 3 ]
            },
            wait: true)

          expect(r).to have_terminated_as_point

          wait_until { @unit.traces.count > 0 }

          expect(@unit.traces.count).to eq(1)
          expect(@unit.traces.first.text).to eq('s0:trap1')
        end
      end

      describe 'bnid: / bind:' do

        it 'binds the trap at a given nid' do

          m = @unit.launch(%q{
            concurrence
              sequence
                stall _
              sequence
                trap tag: 't0' bnid: '0_0_0'
                  def msg \ trace "t0_$(msg.exid)"
                stall _
          }, wait: '0_1_1 receive')

          expect(m['point']).to eq('receive')

          tra = @unit.traps.first

          expect(tra.nid).to eq('0_1_0')
          expect(tra.onid).to eq('0_1_0')
          expect(tra.bnid).to eq('0_0_0')
        end

        it 'triggers a nested blocking trap' do
          # thanks @Subtletree Ryan Scott

          r = @unit.launch(
            %q{
              trace 'a'
              sequence
                trace 'b'
                #trap signal: 'S0' bnid: '0'
                trap signal: 'S0' bind: '0'
                trace 'c'
            })

          wait_until { @unit.traps.count == 1 }

          @unit.signal('S0', exid: r)

          wait_until { @unit.traces.count == 3 }

          expect(
            @unit.traces.collect(&:text)
          ).to eq(%w[
            a b c
          ])
        end
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

        expect(r).to have_terminated_as_point

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
                trace "B>$(node.nid)"
          },
          wait: true)

        expect(r).to have_terminated_as_point

        wait_until { @unit.traces.count > 0 }

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%{
          0:B>0_1_3_0_0_1_0_0
        }.ftrim)
      end
    end

    context 'and cancel/kill' do

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

      it 'cancels its children upon kill' do

        r = @unit.launch(
          %q{
            trap point: 'left'
              def msg \ stall _
            sequence tag: 'x'
            sequence tag: 'y'
            stall _
          },
          wait: '0_3 receive; end')

        exid = r['exid']

        expect(
          @unit.journal.select { |m| m['point'] == 'trigger' }.count
        ).to eq(2)

        exe = @unit.executions[exid: r['exid']]

        expect(
          exe.nodes.keys
        ).to eq(%w[
          0 0_0 0_0_1-1 0_0_1_1-1 0_3 0_0_1-2 0_0_1_1-2
        ])

        @unit.kill(exid: exid, nid: '0_0')

        @unit.wait(exid, 'end')

        exe = @unit.executions[exid: r['exid']]

        expect(exe.status).to eq('active')
        expect(exe.nodes['0_0']['status'].last['status']).to eq('ended')
        expect(exe.nodes['0_0']['cnodes']).to eq([])
#pp exe.nodes['0_0']

        expect(exe.nodes.keys).to eq(%w[ 0 0_0 0_3 ])
      end
    end
  end
end

