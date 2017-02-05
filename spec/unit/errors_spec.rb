
#
# specifying flor
#
# Sun Feb  5 19:48:17 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'uerrs'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'error' do

    it 'lets the execution be saved to storage' do

      r =
        @unit.launch(%{
          sequence
            fail "nada"
        }, wait: true)

      expect(r['point']).to eq('failed')
      sleep 0.3

      expect(@unit.executions.count).to eq(1)

      e = @unit.executions.first

      expect(e.data['nodes'].keys).to eq(%w[ 0 0_0 ])
    end
  end
end

