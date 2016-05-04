
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

  describe 'john doe' do

    it 'flips burgers' do

      fail
    end
  end
end

