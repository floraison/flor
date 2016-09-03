
#
# specifying flor
#
# Fri May 20 14:29:17 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

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

  describe 'trap' do

    it 'traps messages' do

      flon = %{
        sequence
          trap 'terminated'
            def msg; trace "t:$(msg.from)"
          trace "s:$(nid)"
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.100

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        's:0_1_0_0 t:0'
      )
    end

    it 'traps multiple times' do

      flon = %{
        trap point: 'receive'
          def msg; trace "($(nid))=$(msg.from)->$(msg.nid)"
        sequence
          sequence
            trace '*'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.350

      expect(
        #@unit.traces.collect(&:text).join(' | ')
        @unit.traces
          .each_with_index
          .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
      ).to eq(%w{
        0:*
        1:(0_0_1_1_0_0-1)=0_0->0
        2:(0_0_1_1_0_0-2)=0_1_0_0_0_0->0_1_0_0_0
        3:(0_0_1_1_0_0-3)=0_1_0_0_0->0_1_0_0
        4:(0_0_1_1_0_0-4)=0_1_0_0->0_1_0
        5:(0_0_1_1_0_0-5)=0_1_0->0_1
        6:(0_0_1_1_0_0-6)=0_1->0
        7:(0_0_1_1_0_0-7)=0->
      }.collect(&:strip).join("\n"))
    end

    it 'traps in the current execution only by default' do

      exid0 = @unit.launch(%{
        trap tag: 't0'; def msg; trace "t0_$(msg.exid)"
        noop tag: 't0'
        trace "stalling_$(exid)"
        stall _
      })

      sleep 0.5

      r = @unit.launch(%{
        noop tag: 't0'
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

      m = @unit.launch(%{
        sequence
          trap tag: 't0'; def msg; trace "t0_$(msg.exid)"
          stall _
      }, wait: '0_1 receive')

      expect(m['point']).to eq('receive')

      tra = @unit.traps.first

      expect(tra.nid).to eq('0')
      expect(tra.onid).to eq('0_0')
    end

    it 'is removed at the end of the execution' do

      expect(@unit.traps.count).to eq(0)

      r = @unit.launch(%{
        trap tag: 't0'; def msg; trace "t0_$(msg.exid)"
      }, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.4

      expect(@unit.traps.count).to eq(0)
    end

    context 'count:' do

      it 'determines how many times a trap triggers at max' do

        flon = %{
          concurrence
            trap tag: 'b', count: 2
              def msg; trace "A>$(nid)"
            sequence
              sleep 0.8
              noop tag: 'b'
              trace "B>$(nid)"
              noop tag: 'b'
              trace "B>$(nid)"
              noop tag: 'b'
              trace "B>$(nid)"
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

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

        flon = %{
          trap heap: 'sequence'
            def msg; trace "$(msg.point)-$(msg.tree.0)-$(msg.nid)"
          sequence
            noop _
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

        expect(
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }.join("\n")
        ).to eq(%w{
          0:receive--0
          1:execute-sequence-0_1
          2:receive--0_1
          3:receive--0
        }.collect(&:strip).join("\n"))
      end
    end

    context 'heat:' do

      it 'traps given head of trees' do

        flon = %{
          trap heat: 'fun0'; def msg; trace "t-$(msg.tree.0)-$(msg.nid)"
          define fun0; trace "c-fun0-$(nid)"
          sequence
            fun0 # not a call
            fun0 # not a call
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

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

        flon = %{
          trap heat: '_apply'; def msg; trace "t-heat-$(msg.nid)"
          define fun0; trace "c-fun0-$(nid)"
          sequence
            fun0 _
            fun0 _
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

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

        r = @unit.launch(%{
          concurrence
            sequence
              trap tag: 't0'; def msg; trace "in-$(msg.nid)"
              stall tag: 't0'
            sequence
              sleep '1s' # give it time to process the trap
              noop tag: 't0'
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

      it 'traps in the same execution'
    end


    context 'range: domain' do

      it 'traps the events in execution domain' do

        exid0 = @unit.launch(%{
          trap tag: 't0' range: 'domain'; def msg; trace "t0_$(msg.exid)"
          trace "stalling_$(exid)"
          stall _
        }, domain: 'net.acme')

        sleep 0.5

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'org.acme', wait: true)
        exid1 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'net.acme', wait: true)
        exid2 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'net.acme.s0', wait: true)
        exid3 = r['exid']
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
          "1:t0_#{exid2}"
        ].join("\n"))
      end
    end

    context 'range: subdomain' do

      it 'traps the events in range domain and its subdomains' do

        exid0 = @unit.launch(%{
          trap tag: 't0' range: 'subdomain'; def msg; trace "t0_$(msg.exid)"
          trace "stalling_$(exid)"
          stall _
        }, domain: 'net.acme')

        sleep 0.5

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'org.acme', wait: true)
        exid1 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'net.acme', wait: true)
        exid2 = r['exid']
        expect(r['point']).to eq('terminated')

        r = @unit.launch(%{ noop tag: 't0' }, domain: 'net.acme.s0', wait: true)
        exid3 = r['exid']
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
          "1:t0_#{exid2}",
          "2:t0_#{exid3}"
        ].join("\n"))
      end
    end

    context 'tag:' do

      it 'traps tag entered' do

        flon = %{
          sequence
            trace 'a'
            trap tag: 'x'
              def msg; trace msg.point
            sequence tag: 'x'
              trace 'c'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.100

        expect(
          @unit.traces.collect(&:text).join(' ')
        ).to eq(
          'a c entered'
        )
      end
    end

    context 'consumed:' do

      context 'false (default)' do
        it 'traps before the message consumption'
      end
      context 'true' do
        it 'traps after the message consumption'
      end
    end

    context 'multiple criteria' do

      it 'traps messages matching all the criteria' do

        flon = %{
          sequence
            trace 'a'
            trap tag: 'x', point: 'left'
              def msg; trace msg.point
            sequence tag: 'x'
              trace 'c'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.100

# FIXME
#
# fails because when the "left" message happens, the left node has already
# been removed
#
        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a c left
        ])
      end
    end

    context 'without function' do

      it 'blocks once' do

        flon = %{
          concurrence
            trap tag: 'b'
            sequence
              sleep 0.8
              noop tag: 'b'
              noop tag: 'b'
              trace "B>$(nid)"
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

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

