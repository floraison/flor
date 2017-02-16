
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

    it 'fails if it cannot find the subtree'

    it 'grafts a subtree in the current tree' do

      flor = %{
        sequence
          set a []
          graft 'sub0'
          graft 'sub0'
      }

      r = @unit.launch(flor, domain: 'com.acme.alpha', wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq([ 1, 1 ])
    end

    it 'grafts a subtree with function definitions' do

      flor = %{
        set a []
        graft 'sub1_funs'
        stack 1
        stack 2
      }

      r = @unit.launch(flor, domain: 'com.acme.alpha', wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq([ 1, 2 ])
    end
  end
end

