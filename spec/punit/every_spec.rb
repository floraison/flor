
#
# specifying flor
#
# Fri Jan  6 10:20:59 JST 2017  Ishinomaki
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_every'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'every' do

    it 'schedule crons' do

      flor = %{
        every 'day at midnight'
          task 'alpha'
      }

      r = @unit.launch(flor, wait: '0 schedule')

      expect(r['point']).to eq('schedule')
      expect(r['type']).to eq(nil)
      expect(r['string']).to eq('day at midnight')

      sleep 0.4

      expect(@unit.timers.count).to eq(1)

      t = @unit.timers.first
#pp t.values.select { |k, v| k != :content }

      expect(t.type).to eq('cron')
      expect(t.schedule).to eq('every day at midnight')
      expect(t.count).to eq(0)
      expect(t.ntime_t.localtime.day).not_to eq(Time.now.day)
    end
  end
end

