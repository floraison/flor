
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

    @unit.shutdown
  end

  describe 'cancel' do

    context 'nid:' do

      it 'cancels a given nid' do

        r = @unit.launch(
          %q{
            concurrence
              stall _
              stall _
              cancel '0_0'
              cancel nid: '0_1'
          },
          wait: true)

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

        r = @unit.launch(
          %q{
            concurrence
              stall _
              stall _
              stall _
              stall _
              cancel [ '0_0', '0_1' ]
              cancel nid: [ '0_2', '0_3' ]
          },
          wait: true)

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

      it 'may cancel its parent' do

        r = @unit.launch(
          %q{
            concurrence
              cancel '0'
          },
          wait: true)

        sleep 0.35

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .reject { |m| m['point'] == 'end' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
            .join("\n")
        ).to eq(%w[
          :execute:0
          0:execute:0_0
          0_0:execute:0_0_0
          0_0_0:execute:0_0_0_0
          0_0_0_0:receive:0_0_0
          0_0_0:receive:0_0
          0_0:cancel:0
          0:cancel:0_0
          0_0:receive:0
          0:receive:
          0:terminated:
        ].collect(&:lstrip).join("\n"))
      end
    end

    context 'ref:' do

      it 'cancels a given tag' do

        r = @unit.launch(
          %q{
            concurrence
              stall tag: 'a'
              stall tag: 'b'
              sequence # wrap in sequence to give time to stall
                cancel 'a'
              sequence # wrap in sequence to give time to stall
                cancel ref: 'b'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
            .join("\n")
        ).to eq(%w[
          0_2_0:cancel:0_0
          0_3_0:cancel:0_1
        ].join("\n"))
      end

      it 'can cancel multiple tags' do

        r = @unit.launch(
          %q{
            concurrence
              stall tag: 'a'
              stall tag: 'b'
              stall tag: 'c'
              stall tag: 'd'
              sequence
                # give time to tag 'a' and 'b' to be entered
                cancel [ 'a', 'b' ]
              cancel ref: [ 'c', 'd' ]
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_4_0:cancel:0_0
          0_4_0:cancel:0_1
          0_5:cancel:0_2
          0_5:cancel:0_3
        ])
      end
    end

    context 'without keyed att' do

      it 'cancels nids or tags' do

        r = @unit.launch(
          %q{
            concurrence
              stall tag: 'a'
              stall tag: 'b'
              stall tag: 'c'
              stall tag: 'd'
              stall tag: 'e'
              stall tag: 'f'
              sequence
                # give time to tag 'a', 'b', '0_2' to be entered
                cancel [ 'a', 'b', '0_2' ]
              cancel '0_3', 'e', '0_5'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          @unit.journal
            .select { |m| m['point'] == 'cancel' }
            .collect { |m| [ m['from'], m['point'], m['nid'] ].join(':') }
        ).to eq(%w[
          0_6_0:cancel:0_2
          0_6_0:cancel:0_0
          0_6_0:cancel:0_1
          0_7:cancel:0_3
          0_7:cancel:0_5
          0_7:cancel:0_4
        ])
      end
    end

    it "cancels all when '0'" do

      r = @unit.launch(
        %q{
          concurrence
            stall _
            cancel '0'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['cause'].size).to eq(2)
    end
  end

  describe 'kill' do

    it 'kills a branch' do

      r = @unit.launch(
        %q{
          concurrence
            sequence
              stall _
            sequence
              _skip 1
              kill '0_0'
        },
        archive: true,
        wait: true)

      expect(r['point']).to eq('terminated')

      seq = @unit.archive[r['exid']]['0_0']

      expect(
        F.to_s(seq, :status)
      ).to eq(%{
        (status ended pt:receive fro:0_0 m:21)
        (status closed pt:cancel fla:kill fro:0_1_1 m:18)
        (status o pt:execute)
      }.ftrim)

      sta = @unit.archive[r['exid']]['0_0_0']

      expect(
        F.to_s(sta, :status)
      ).to eq(%{
        (status ended pt:receive fro:0_0_0 m:23)
        (status closed pt:cancel fla:kill fro:0_0 m:20)
        (status o pt:execute)
      }.ftrim)

      sleep 0.3

      expect(
        @unit.journal
          .reject { |m| m['point'] == 'end' }
          .collect { |m| [ m['nid'], m['point'], m['flavour'].to_s ].join(':') }
          .join("\n")
      ).to eq(%w[
        0:execute:
        0_0:execute:
        0_1:execute:
        0_0_0:execute:
        0_1_0:execute:
        0_0_0_0:execute:
        0_1_0_0:execute:
        0_0_0:receive:
        0_1_0_0_0:execute:
        0_1_0_0:receive:
        0_1_0:receive:
        0_1:receive:
        0_1_1:execute:
        0_1_1_0:execute:
        0_1_1_0_0:execute:
        0_1_1_0:receive:
        0_1_1:receive:
        0_0:cancel:kill
        0_1:receive:
        0_0_0:cancel:kill
        0:receive:
        0:receive:
        0_0:receive:
        :receive:
        :terminated:
      ].join("\n"))
    end
  end
end

