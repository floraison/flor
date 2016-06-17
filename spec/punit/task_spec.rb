
#
# specifying flor
#
# Thu Jun 16 21:20:42 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

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

  describe 'task' do

    it 'tasks' do

      flon = %{
        task 'alfred'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })
    end
  end
end

