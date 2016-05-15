
#
# specifying flor
#
# Sat May 14 07:02:08 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf')
    @unit.conf[:unit] = 'pu_sleep'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'sleep' do

    it 'creates a timer' do

      flon = %{
        sleep 1y
      }

      exid = @unit.launch(flon)

      sleep 1

      ts = @unit.timers.all
      t = ts.first
      td = t.data

      expect(ts.count).to eq(1)
      expect(t.exid).to eq(exid)
      expect(t.type).to eq('at')
      expect(t.schedule).to eq('1y')
pp td
      expect(td['message']['point']).to eq('receive')
    end

    it 'does not sleep when t <= 0'

    it 'makes an execution sleep for a while' do

      flon = %{
        sleep 1s
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg.class).to eq(Hash)
      expect(msg['point']).to eq('terminated')
    end
  end
end

