
#
# specifying flor
#
# Fri Jun  3 06:09:21 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf')
    @unit.conf[:unit] = 'pu_sleep'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'concurrence' do

    it 'has no effect when empty' do

      flon = %{
        concurrence _
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg['point']).to eq('terminated')
    end

    it 'executes atts in sequence then children in concurrence' do

      flon = %{
        concurrence tag: 'x', nada: 'y'
          trace 'a'
          trace 'b'
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg['point']).to eq('terminated')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b'
      )
    end
  end
end

