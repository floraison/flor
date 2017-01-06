
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
        every 'day at noon'
          task 'alpha'
      }

      r = @unit.launch(flor, wait: true)

      #expect(r['point']).to eq('terminated')
      #expect(r['vars']['l']).to eq(%w[ requested done. approved ])
    end
  end
end

