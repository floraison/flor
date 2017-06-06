
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

      [ "range 0", [] ],
      [ "range 8", (0..7).to_a ],

      [ "range 1 8", (1..7).to_a ],

      [ "range 1 8 2", (1..7).step(2).to_a ],

    ].each do |flor, expected|

      it "`#{flor}` returns #{expected.inspect}" do

        r = @executor.launch(flor)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(expected)
      end
    end
  end
end

