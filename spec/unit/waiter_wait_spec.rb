
#
# specifying flor
#
# Tue Jan 24 07:42:13 JST 2017
#

require 'spec_helper'


describe Flor::Waiter do

  context 'and Unit#wait' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf['unit'] = 'unitwaittest'
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start
    end

    after :each do

      @unit.shutdown
    end

    it 'lets wait until the scheduler gets idle' do

      @unit.launch(%{ sleep 10 })

      sleep 1

      #r = @unit.wait(nil, 'idle')
      r = @unit.wait('idle')

      expect(r['point']).to eq('idle')
      expect(r['exid']).to eq(nil)

      expect(r.keys).to eq(%w[
        point idle_count consumed ])

      expect(r['idle_count']).to be > 0
    end
  end
end

