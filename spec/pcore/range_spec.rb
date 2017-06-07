
#
# specifying flor
#
# Wed Jun  7 05:03:47 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'range' do

    [

      #[ "range -4", [ 0, -1, -2, -3 ] ],
      [ "range (-4)", [ 0, -1, -2, -3 ] ],

      [ "range 0", [] ],
      [ "range 8", (0..7).to_a ],

      [ "range 1 8", (1..7).to_a ],
      [ "range 8 4", [ 8, 7, 6, 5 ] ],
      [ "range 3 (-3)", [ 3, 2, 1, 0, -1, -2 ] ],

      [ "range 1 8 2", (1..7).step(2).to_a ],
      [ "range 9 1 (-2)", [ 9, 7, 5, 3 ] ]

    ].each do |flor, expected|

      it "`#{flor}` returns #{expected.inspect}" do

        r = @executor.launch(flor)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(expected)
      end
    end

    it 'rejects a step set to 0' do

      r = @executor.launch(%q{ range 1 8 0 })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('range step is 0')
    end
  end
end

