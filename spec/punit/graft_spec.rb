
#
# specifying flor
#
# Thu Feb 16 21:47:27 JST 2017
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'graftest'
    #@unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'graft' do

    it 'grafts a subflow in the current flow' do

      flor = %{
        sequence
          set a []
          graft 'subflow0'
          graft 'subflow0'
      }

      r = @unit.launch(flor, domain: 'com.acme.alpha', wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq([ 1, 1 ])
    end
  end
end

