
#
# specifying flor
#
# Tue Dec 20 16:52:02 JST 2016
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

  describe 'on' do

    it 'traps signals' do

      flor = %{
        set l []
        on 'approve'
          push l 'approved'
        push l 'requested'
        signal 'approve'
        push l 'done.'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ requested done. approved ])
    end

    it 'traps signals and their payload' do

      flor = %{
        set l []
        push l 'a'
        on 'approve'
          push l sig
          push l msg.payload.ret
        signal 'approve'
          'b'
        push l 'c'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ a c approve b ])
    end
  end
end

