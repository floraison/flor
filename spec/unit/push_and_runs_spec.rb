
#
# specifying flor
#
# Wed Jan 18 17:09:05 SGT 2017  Singapore
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

  describe 'push (run spanning)' do

    it 'works' do

      r =
        @unit.launch(%{
          set l []
          push l 0
          sleep 0
          push l 1
        }, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 1 ])
    end
  end
end

