
#
# specifying flor
#
# Thu Jul 14 07:02:52 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_cancel'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'cancel' do

    context 'nid:' do

      it 'cancels a given nid' do

        flon = %{
          concurrence
            stall _
            stall _
            cancel '0_0'
            cancel nid: '0_1'
        }

        r = @unit.launch(flon, wait: true)

        expect(r['point']).to eq('terminated')
      end
    end

    context 'ref:' do
      it 'cancels a given tag'
    end
  end
end

