
#
# specifying flor
#
# Wed Jun  1 13:37:07 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf')
    @unit.conf['unit'] = 'u'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'a timeout' do

    it 'sets a timer' do

      flon = %{
        sequence
          #stall timeout: 60
          stall timeout: 60, tag: 'never'
      }

      exid = @unit.launch(flon)

      sleep 1

      ts = @unit.timers.all

      expect(ts.size).to eq(1)
    end

    it 'triggers after the given time'
    it 'is removed after triggering'
    it 'is removed if the node ends before timing out'
  end
end

