
#
# specifying flor
#
# Thu Nov 16 17:42:10 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'keys' do

    it 'returns the keys for an object' do

      r = @executor.launch(
        %q{
          keys [ 1, 'b', 3 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 1, 2 ])
    end

    it 'returns the indexes for an array' do

      r = @executor.launch(
        %q{
          keys { a: 'A', b: 'B' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ a b ])
    end

    it 'fails when not array or object' do

      r = @executor.launch(
        %q{
          #keys _
          keys "x"
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('Received argument of class String, no keys')
    end

    it 'fails when no argument' do

      r = @executor.launch(
        %q{
          keys _
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('No argument given')
    end
  end
end

