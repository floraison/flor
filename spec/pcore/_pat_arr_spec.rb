
#
# specifying flor
#
# Sun May 21 10:40:12 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_arr' do

    [

      [ %q{ _pat_arr \ 7 }, [ 6 ], nil ],
      [ %q{ _pat_arr \ 7 }, [ 7 ], {} ],
      [ %q{ _pat_arr \ a }, [ 5 ], { 'a' => 5 } ]

    ].each do |code, val, expected|

      it(
        "#{expected == nil ? 'doesn\'t match' : 'matches'}" +
        " for #{code.strip.inspect}"
      ) do

        r = @executor.launch(code, payload: { 'ret' => val })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']['_pat_binding']).to eq(expected)
      end
    end
  end
end

