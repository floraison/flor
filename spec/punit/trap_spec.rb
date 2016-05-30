
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
          #  trace 'x'
          trap 'terminated'
            trace 't'
          trace 's'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.100

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        's t'
      )
    end

    it 'traps tags' do

      flon = %{
        sequence
          trace 'a'
          trap tag: 'x'
            trace 'b'
          sequence tag: 'x'
            trace 'c'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.100

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b c'
      )
    end
  end
end

