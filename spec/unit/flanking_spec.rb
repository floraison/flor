# encoding: UTF-8

#
# specifying flor
#
# Tue Mar 28 07:40:11 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'uflanking'
    #@unit.hook('journal', Flor::Journal)
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

      ms = @unit.launch(flor, wait: '0_2 receive')

      exe = @unit.executions[exid: ms['exid']].data

      n_0 = exe['nodes']['0']
      n_0_0 = exe['nodes']['0_0']

      expect(n_0_0).not_to eq(nil)
      expect(n_0_0['parent']).to eq(nil)
      expect(n_0_0['oparent']).to eq('0')
      expect(n_0_0['tree'][0]).to eq('sequence')
      expect(n_0_0['tree'][1][0]).to eq([ '_att', [ [ 'flank', [], 3 ] ], 3 ])

      expect(n_0['cnodes']).to eq(%w[ 0_0 0_2 ])
    end

    context 'upon cancellation' do

      it 'gets cancelled like other cnodes'
    end
  end
end

