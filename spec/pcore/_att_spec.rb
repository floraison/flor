
#
# specifying flor
#
# Sun Jul  7 23:39:20 JST 2019  Changi O'Learys sportsbar
#

require 'spec_helper'


describe Flor::Pro::Att do

  describe '#timers_to_arrays (protected)' do

    {

      '3d remind' =>
        [ [ '3d', 'remind' ] ],
      '3d: remind' =>
        [ [ '3d', 'remind' ] ],
      '3d: a, 4d: b' =>
        [ [ '3d', 'a', '4d', 'b' ] ],
      '3d: a, 4d: b; 2d c' =>
        [ [ '3d', 'a', '4d', 'b' ], [ '2d', 'c' ] ],

    }.each do |input, output|

      it "groks #{input.inspect}" do

        expect(
          Flor::Pro::Att.allocate.send(:timers_to_arrays, input)
        ).to eq(
          output
        )
      end
    end
  end
end

