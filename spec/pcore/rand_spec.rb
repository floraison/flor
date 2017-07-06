
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

      r = @executor.launch(%{ rand 10 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
      expect(r['payload']['ret']).to be_an(Integer)
    end

    it 'takes the current ret as max' do

      r = @executor.launch(
        %q{
          10
          rand _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0, 10)
      expect(r['payload']['ret']).to be_an(Integer)
    end

    it 'returns a float when given a float' do

      r = @executor.launch(%{ rand 10.0 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(0.0, 10.0)
      expect(r['payload']['ret']).to be_a(Float)
    end

    it 'fails gracefully when it cannot deal with its argument' do

      r = @executor.launch(%{ rand "abcd" })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("'rand' expects an integer or a float")
    end

    it 'accepts two arguments (range 2 11)' do

      r = @executor.launch(%{ rand 2 11 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(2, 11)
      expect(r['payload']['ret']).to be_a(Integer)
    end

    it 'accepts two arguments (range 2 11.5)' do

      r = @executor.launch(%{ rand 2 11.5 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(2, 11.5)
      expect(r['payload']['ret']).to be_a(Float)
    end
  end
end

