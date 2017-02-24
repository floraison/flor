
#
# specifying flor
#
# Sat Feb 25 06:20:45 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'rand' do

    it 'returns a random integer' do

      flor = %{
        rand 10
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
    end

    it 'takes the current ret as max' do

      flor = %{
        10
        rand _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
    end
  end
end

