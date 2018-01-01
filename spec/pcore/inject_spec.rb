
#
# specifying flor
#
# Tue Jan  2 07:51:56 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'inject' do

    it 'reduces with a func' do

      r = @executor.launch(
        %q{
          inject [ '0', 1, 'b', 3 ]
            res + elt
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b3')
    end

    it 'reduces with a func and a start value' do

      r = @executor.launch(
        %q{
          inject [ 0, 1, 2, 3 ] 7
            res + elt
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(13)
    end

    it 'reduces with a func and a start value' do

      r = @executor.launch(
        %q{
          inject 7 [ 1, 2, 3, 4 ]
            res + elt
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(17)
    end
  end
end

