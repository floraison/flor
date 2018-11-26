
#
# specifying flor
#
# Sun Nov 25 11:55:00 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sort' do

    context 'without a function' do

      it 'sorts' do

        r = @executor.launch(
          %q{
            sort [ 0 7 1 5 3 4 2 6 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ 0, 1, 2, 3, 4, 5, 6, 7 ])
      end

      it 'sorts heterogeneous values' do

        r = @executor.launch(
          %q{
            sort [ 0 null 1.1 true "false" [ 0 1 ] { c: 2 } ]
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['ret']
        ).to eq([
          0, 1.1, [ 0, 1 ], "false", nil, true, { 'c' => 2 }
        ])
      end
    end

    context 'with a function' do

      it 'sorts'
    end
  end
end

