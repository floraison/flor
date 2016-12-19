
#
# specifying flor
#
# Mon Dec 19 11:27:09 JST 2016
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

  describe 'cursor' do

    it 'goes from a to b and exits' do

      flon = %{
        cursor
          push f.l 0
          push f.l 1
        push f.l 2
      }

      r = @unit.launch(flon, payload: { 'l' => [] }, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end
  end
end

