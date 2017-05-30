
#
# specifying flor
#
# Wed May 31 05:14:14 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'length' do

    it 'returns the length of its argument' do

      r = @executor.launch(
        %q{
          [
            (length a0)
            (length a1)
            (length h0)
            (length h0.a)
            (length h0.b)
          ]
        },
        vars: { 'a0' => [], 'a1' => [ 1, 2 ], 'h0' => { 'a' => 0 } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 2, 1, -1, -1 ])
    end
  end
end

