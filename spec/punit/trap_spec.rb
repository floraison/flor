
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

    it 'traps tags' do

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

    it 'traps in the current execution only' do

      exid0 = @unit.launch(%{
        trap tag: 't0'; def msg; trace "t0_$(msg.exid)"
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
          [ exid0, exid1 ] +
          @unit.traces
            .each_with_index
            .collect { |t, i| "#{i}:#{t.text}" }
        ).join("\n")
      ).to eq([
        exid0,
        exid1,
        "0:stalling_#{exid0}"
      ].join("\n"))
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
          trap heat: '_apply'; def msg; trace "t-$(node.heat.0)-$(msg.nid)"
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
          1:t-_proc-0_1-1
          2:t-_proc-0_1-1
          3:t-_proc-0_1-1
          4:c-fun0-0_1_1_0_0-5
          5:t-_proc-0_1-5
          6:t-_proc-0_1-5
          7:t-_proc-0_1-5
        }.collect(&:strip).join("\n"))
      end
    end

    context 'heap:' do

      it 'traps given procedures' do

        flon = %{
          trap heap: 'sequence'
            def msg; trace "$(msg.tree.0)-$(msg.nid)"
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
          0:-0
          1:sequence-0_1
          2:-0_1
          3:-0
        }.collect(&:strip).join("\n"))
      end
    end

    context 'without function' do

      it 'blocks once' do

        flon = %{
          concurrence
            sequence
              trap tag: 'b'
              trace "A>$(nid)"
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
          0:A>0_0_1_0_0
          1:B>0_1_3_0_0
        }.collect(&:strip).join("\n"))
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

        expect(
          @unit.traces.collect(&:text)
        ).to eq(%w[
          a c left
        ])
      end
    end

    context 'count:' do

      it 'determines how many times a trap triggers at max' do

        flon = %{
          concurrence
            sequence
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
          1:A>0_0_0_2_1_0_0-1
          2:B>0_1_4_0_0
          3:A>0_0_0_2_1_0_0-2
          4:B>0_1_6_0_0
        }.collect(&:strip).join("\n"))
      end
    end

    context 'exid: any' do

      it 'lets trap trigger for any execution' do

        exid0 = @unit.launch(%{
          trap tag: 't0', exid: 'any'
            def msg; trace "t0_$(msg.exid)"
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
            [ exid0, exid1 ] +
            @unit.traces
              .each_with_index
              .collect { |t, i| "#{i}:#{t.text}" }
          ).join("\n")
        ).to eq([
          exid0,
          exid1,
          "0:stalling_#{exid0}",
          "1:t0_#{exid1}"
        ].join("\n"))
      end
    end
  end
end

