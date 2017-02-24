
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

      flor = %{ rand 10 }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
      expect(r['payload']['ret']).to be_an(Integer)
    end

    it 'takes the current ret as max' do

      flor = %{
        10
        rand _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
      expect(r['payload']['ret']).to be_an(Integer)
    end

    it 'returns a float when given a float' do

      flor = %{ rand 10.0 }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0.0, 10.0)
      expect(r['payload']['ret']).to be_a(Float)
    end

    it 'fails gracefully when it cannot deal with its argument' do

      flor = %{ rand "abcd" }

      r = @executor.launch(flor)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("'rand' expects an integer or a float")
    end

    it 'accepts two arguments (range 2 11)' do

      flor = %{ rand 2 11 }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(2, 11)
      expect(r['payload']['ret']).to be_a(Integer)
    end

    it 'accepts two arguments (range 2 11.5)' do

      flor = %{ rand 2 11.5 }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(2, 11.5)
      expect(r['payload']['ret']).to be_a(Float)
    end
  end
end

