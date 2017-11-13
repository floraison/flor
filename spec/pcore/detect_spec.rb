
#
# specifying flor
#
# Tue Nov 14 05:39:20 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'detect' do

    it 'finds the first matching element' do

      r = @executor.launch(
        %q{
          detect [ 1, 2, 3 ]
            (elt % 2) == 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end

    context 'with objects' do

      it 'finds the first matching element'
    end
  end
end

