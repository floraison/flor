
#
# specifying flor
#
# Fri Jun  3 06:09:21 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_concurrence'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'concurrence' do

    it 'has no effect when empty' do

      flor = %{
        concurrence _
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')
    end

    it 'has no effect when empty (2)' do

      flor = %{
        concurrence tag: 'z'
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')

      sleep 0.4 # for jruby

      expect(
        @unit.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:z
        receive:0:
        receive::
        left:0:z
        terminated::
      ].join("\n"))
    end

    it 'executes atts in sequence then children in concurrence' do

      flor = %{
        concurrence tag: 'x', nada: 'y'
          trace 'a'
          trace 'b'
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b'
      )

      expect(
        @unit.journal
          .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
      ).to comprise(%w[
        exe:0_2 exe:0_3
        exe:0_2_0 exe:0_3_0
        exe:0_2_0_0 exe:0_3_0_0
      ])
    end

    describe 'by default' do

      it 'merges all the payload, first reply wins' do

        flor = %{
          concurrence
            set f.a 0
            set f.a 1
            set f.b 2
        }

        msg = @unit.launch(flor, wait: true)

        expect(msg['point']).to eq('terminated')
        expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0, 'b' => 2 })
      end
    end

    describe 'expect:' do

      it 'accepts an integer > 0' do

        flor = %{
          concurrence expect: 1
            set f.a 0
            set f.b 1
        }

        msg = @unit.launch(flor, wait: true)

        expect(msg['point']).to eq('terminated')
        expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0 })

        sleep 0.350

        expect(
          @unit.journal
            .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
        ).to comprise(%w[
          rec:0 rec:0 can:0_2 rec: ter:
        ])
      end
    end

    describe 'remaining:' do

      it 'prevents child cancelling when "forget"' do

        flor = %{
          concurrence expect: 1 rem: 'forget'
            set f.a 0
            set f.b 1
        }

        msg = @unit.launch(flor, wait: true)

        expect(msg['point']).to eq('terminated')
        expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0 })

        sleep 0.4

        expect(
          @unit.journal
            .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
        ).to comprise(%w[
          rec:0 rec:0 rec: ter:
        ])
      end
    end

    context 'upon cancelling' do

      it 'cancels all its children' do

        flor = %{
          concurrence
            task 'hole'
            task 'hole'
        }

        msg = @unit.launch(flor, wait: '0_1 task')

        r = @unit.queue(
          { 'point' => 'cancel', 'exid' => msg['exid'], 'nid' => '0' },
          wait: true)

        expect(r['point']).to eq('terminated')

        sleep 0.350

        expect(
          @unit.journal
            .drop_while { |m|
              m['point'] != 'task' }
            .collect { |m|
              [ "m#{m['m']}s#{m['sm']}",
                "e#{m['er']}p#{m['pr']}",
                m['point'], m['nid'] ].join('-') }
            .join("\n")
        ).to eq(%w[
              m12s10-e1p1-task-0_0
              m13s11-e1p1-task-0_1
            m14s-ep2-cancel-0
              m15s14-e2p2-cancel-0_0
              m16s14-e2p2-cancel-0_1
              m17s15-e2p2-detask-0_0
              m18s16-e2p2-detask-0_1
              m19s-ep3-return-0_0
              m20s-ep3-return-0_1
              m21s-e3p3-receive-0_0
              m22s-e3p3-receive-0_1
            m23s21-e3p3-receive-0
            m24s22-e3p3-receive-0
          m25s24-e3p3-receive-
          m26s25-e3p3-terminated-
        ].join("\n"))
      end
    end
  end
end

