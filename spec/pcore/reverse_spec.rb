
#
# specifying flor
#
# Thu Jun 15 15:56:45 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'reverse' do

    it 'reverses the f.ret array' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3 ]
          reverse _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 2, 1 ])
    end

    it 'reverses arrays' do

      r = @executor.launch(
        %q{
          reverse [ 1, 2, 3 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 2, 1 ])
    end
  end
end

