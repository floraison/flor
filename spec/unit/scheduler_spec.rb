
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

      @unit.launch(flon)
    end
  end
end

