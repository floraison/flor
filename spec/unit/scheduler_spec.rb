
#
# specifying flor
#
# Wed May  4 15:59:30 JST 2016
# Golden Week
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf').start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
  end

  describe 'scheduler' do

    it 'runs a simple flow' do

      flon = %{
        sequence
          define sum a, b
            +
              a
              b
          sum 1 2
      }

      exid = @unit.launch(flon)

      expect(
        exid
      ).to match(
        /\Adomain0-u0-#{Time.now.year}\d{4}\.\d{4}\.[a-z]+\z/
      )

      ms = @unit.storage.db[:flon_messages].all
      m = ms.first

      expect(ms.size).to eq(1)
      expect(m[:exid]).to eq(exid)
      expect(m[:point]).to eq('execute')
      expect(JSON.parse(m[:content])['exid']).to eq(exid)
      fail
    end
  end
end

