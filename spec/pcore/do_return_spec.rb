
#
# specifying flor
#
# Fri May  5 09:45:22 JST 2017  Obscure Coffee Roasters Hiroshima
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'do-return' do

    it 'returns a function that returns its argument' do

      r = @executor.launch(
        %q{
          set a
            do-return 1
          set b \ (do-return 'two')
          [ (a _) (b _) ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 'two' ])
    end
  end
end

