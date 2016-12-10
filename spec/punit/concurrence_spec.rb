
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

      flon = %{
        concurrence _
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg['point']).to eq('terminated')
    end

    it 'has no effect when empty (2)' do

      flon = %{
        concurrence tag: 'z'
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg['point']).to eq('terminated')

      sleep 0.4 # for jruby

      expect(
        @unit.journal
          .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
      ).to eq(%w[
        exe:0 exe:0_0 exe:0_0_1 rec:0_0 ent:0 rec:0 rec: lef:0 ter:
      ])
    end

    it 'executes atts in sequence then children in concurrence' do

      flon = %{
        concurrence tag: 'x', nada: 'y'
          trace 'a'
          trace 'b'
      }

      msg = @unit.launch(flon, wait: true)

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

        flon = %{
          concurrence
            set f.a 0
            set f.a 1
            set f.b 2
        }

        msg = @unit.launch(flon, wait: true)

        expect(msg['point']).to eq('terminated')
        expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0, 'b' => 2 })
      end
    end

    describe 'expect:' do

      it 'accepts an integer > 0' do

        flon = %{
          concurrence expect: 1
            set f.a 0
            set f.b 1
        }

        msg = @unit.launch(flon, wait: true)

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

        flon = %{
          concurrence expect: 1 rem: 'forget'
            set f.a 0
            set f.b 1
        }

        msg = @unit.launch(flon, wait: true)

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

        flon = %{
          concurrence
            task 'hole'
            task 'hole'
        }

        msg = @unit.launch(flon, wait: '0_1 task')

        r = @unit.queue(
          { 'point' => 'cancel', 'exid' => msg['exid'], 'nid' => '0' },
          wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .drop_while { |m| m['point'] != 'task' }
            .collect { |m| "#{m['point']}-#{m['nid']}" }
        ).to eq(%w[
            task-0_0
            task-0_1
          cancel-0
            cancel-0_0
            cancel-0_1
          receive-
            detask-0_0
            detask-0_1
          terminated-
        ])
      end
    end
  end
end

