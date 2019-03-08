
#
# specifying flor
#
# Sun Dec 25 06:47:51 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'Flor::Execution' do

    it 'lists the current tags' do

      r =
        @unit.launch(%{
          concurrence
            sequence tag: 'aa'
              stall _
            sequence tag: [ 'bb', 'cc' ]
              stall _
        }, wait: '0_1_1 execute')

      expect(r['point']).to eq('execute')

      exe = wait_until { @unit.executions[exid: r['exid']] }

      expect(exe.tags).to eq(%w[ aa bb cc ])
    end

    it 'lists an empty array if there are no tags' do

      r =
        @unit.launch(%{
          concurrence
            sequence
              stall _
        }, wait: '0_0_0_0 execute')

      expect(r['point']).to eq('execute')

      exe = wait_until { @unit.executions[exid: r['exid']] }

      expect(exe.tags).to eq([])
    end
  end
end

