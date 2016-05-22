
#
# specifying flor
#
# Fri May 20 14:29:17 JST 2016
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

  describe 'trap' do

    it 'fails when children count < 2' do

      flon = %{
        trap 'execute'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('trap requires at least one child node')
    end

    it 'traps messages' do

      flon = %{
        sequence
          #trap 'execute'
          #  push l 'x'
          trap 'terminated'
            push gv.l 'z'
          push gv.l 'y'
          push gv.l 'y'
      }

      r = @unit.launch(flon, vars: { 'l' => [] }, wait: true)

#pp r
      expect(r['point']).to eq('terminated')
sleep 1
      expect(r['vars']['l']).to eq(%w[ x x x y x y z ])

      expect(@unit.traps.count).to eq(0)
    end
  end
end

