# encoding: UTF-8

#
# specifying flor
#
# Tue Mar 28 07:40:11 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json', 'archive' => true)
    @unit.conf['unit'] = 'uflanking'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a flanking node' do

    it 'responds but is not removed from parent cnodes' do

      flor = %{
        sequence
          sequence flank
            stall _
          sequence _
          stall _
      }

      r = @unit.launch(flor, wait: 'end')

      exe = @unit.executions[exid: r['exid']].data

      n_0 = exe['nodes']['0']
      n_0_0 = exe['nodes']['0_0']

      expect(n_0_0).not_to eq(nil)
      expect(n_0_0['parent']).to eq(nil)
      expect(n_0_0['fparent']).to eq('0')
      expect(n_0_0['tree'][0]).to eq('sequence')
      expect(n_0_0['tree'][1][0]).to eq([ '_att', [ [ 'flank', [], 3 ] ], 3 ])

      expect(n_0['cnodes']).to eq(%w[ 0_0 0_2 ])
    end

    context 'upon cancellation' do

      it 'gets cancelled like other cnodes' do

        flor = %{
          sequence
            sequence flank
              stall _
            stall _
        }

        r = @unit.launch(flor, wait: 'end')
        exid = r['exid']

        exe = @unit.executions[exid: exid].data
        n_0 = exe['nodes']['0']

        expect(n_0['cnodes']).to eq(%w[ 0_0 0_1 ])

        @unit.cancel(exid: exid, nid: '0')
        r = @unit.wait(exid)

        expect(r['point']).to eq('terminated')

        n_0_0 = @unit.archived_node(exid, '0_0')

        expect(
          Flor.node_status_to_s(n_0_0)
        ).to eq(%{
          (status ended pt:receive fro:0_0 m:23)
          (status closed pt:cancel fro:0 m:17)
          (status o pt:execute)
        }.ftrim)


        expect(
          Flor.to_s(
            @unit.journal.drop_while { |m| m['point'] != 'end' }[1..-1])
        ).to eq(%{
          (msg 0 cancel)
          (msg 0_0 cancel from:0)
          (msg 0_1 cancel from:0)
          (msg 0_0_1 cancel from:0_0)
          (msg 0 receive from:0_1)
          (msg 0_0 receive from:0_0_1)
          (msg  receive from:0)
          (msg  receive from:0_0)
          (msg 0_0 cancel from:0)
          (msg  ceased from:0_0)
          (msg  terminated from:0)
        }.ftrim)
      end
    end

    context 'when flanked nodes replies to its parent' do

      it 'gets cancelled'

#        flor = %{
#          sequence
#            sequence flank
#              stall _
#            sleep 0.140
#        }
#
#        r = @unit.launch(flor, wait: true)
#
#        expect(r['point']).to eq('terminated')
#
#        sleep 0.490
#
#        # check execution
#
#        exid = r['exid']
#
#        exe = @unit.executions[exid: exid]
#
#        expect(exe.failed?).to eq(false)
#        expect(exe.status).to eq('terminated')
#        expect(exe.nodes.keys).to eq(%w[ 0 ])
#
#        # check journal
#
#        j = @unit.journal
#
#        expect(j).to include_msg(
#          point: 'cancel', nid: '0_0', from: '0', deflank: true)
#        expect(j).to include_msg(
#          point: 'cancel', nid: '0_0_1', from: '0_0')
#        expect(j).to include_msg(
#          point: 'ceased', from: '0_0')
#      end
    end
  end
end

