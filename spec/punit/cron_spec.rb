
#
# specifying flor
#
# Mon Sep 18 15:49:33 JST 2017
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'cron' do

    it 'schedules' do

      r = @unit.launch(
        %q{
          cron '0 0 1 jan *'
            alpha _
            bravo _
          stall _
        },
        wait: 'end')

      expect(r['point']).to eq('end')

      expect(@unit.timers.count).to eq(1)
    end

    it 'triggers' do

      r = @unit.launch(
        %q{
          cron '* * * * * *'
            1
          stall _
        },
        wait: 'trigger')

      expect(r['point']).to eq('trigger')
      expect(r['m']).to eq(17)
      expect(r['sm']).to eq(12) # the 'schedule' message
    end
  end
end

