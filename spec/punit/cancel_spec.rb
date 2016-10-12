
#
# specifying flor
#
# Thu Jul 14 07:02:52 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_cancel'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

  end

  describe 'cancel' do

    context 'nid:' do

      it 'cancels a given nid' do

        flon = %{
          concurrence
            stall _
            stall _
            cancel '0_0'
            cancel nid: '0_1'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_2:cancel:0_0
          0_3:cancel:0_1
        ])
      end

      it 'can cancel multiple nids' do

        flon = %{
          concurrence
            stall _
            stall _
            stall _
            stall _
            cancel [ '0_0', '0_1' ]
            cancel nid: [ '0_2', '0_3' ]
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_4:cancel:0_0
          0_4:cancel:0_1
          0_5:cancel:0_2
          0_5:cancel:0_3
        ])
      end
    end

    context 'ref:' do

      it 'cancels a given tag' do

        flon = %{
          concurrence
            stall tag: 'a'
            stall tag: 'b'
            cancel 'a'
            cancel ref: 'b'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_2:cancel:0_0
          0_3:cancel:0_1
        ])
      end

      it 'can cancel multiple tags' do

        flon = %{
          concurrence
            stall tag: 'a'
            stall tag: 'b'
            stall tag: 'c'
            stall tag: 'd'
            cancel [ 'a', 'b' ]
            cancel ref: [ 'c', 'd' ]
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_4:cancel:0_0
          0_4:cancel:0_1
          0_5:cancel:0_2
          0_5:cancel:0_3
        ])
      end
    end

    context 'without keyed att' do

      it 'cancels nids or tags' do

        flon = %{
          concurrence
            stall tag: 'a'
            stall tag: 'b'
            stall tag: 'c'
            stall tag: 'd'
            stall tag: 'e'
            stall tag: 'f'
            cancel [ 'a', 'b', '0_2' ]
            cancel '0_3', 'e', '0_5'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_6:cancel:0_2
          0_6:cancel:0_0
          0_6:cancel:0_1
          0_7:cancel:0_3
          0_7:cancel:0_5
          0_7:cancel:0_4
        ])
      end
    end
  end
end

