
#
# specifying flor
#
# Mon Mar 28 16:35:30 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'map' do

    it 'maps elements' do

      flon = %{
        map [ 1, 2, 3 ]
          def x
            + x 3
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 4, 5, 6 ])
    end

    it 'maps f.ret by default' do

      flon = %{
        [ 1, 2, 3 ]
        map
          def x
            + x 2
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 4, 5 ])
    end

    it 'maps to a function by its name' do

      flon = %{
        define add3 x
          + x 3
        map [ 0, 1 ] add3
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 4 ])
    end
  end
end

