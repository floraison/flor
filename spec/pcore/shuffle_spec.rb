
#
# specifying flor
#
# Tue Aug 14 09:57:38 CEST 2018  Neyruz
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'shuffle' do

    it 'shuffles an array' do

      r = @executor.launch(
        %q{
          [ 0 1 2 3 4 5 6 7 8 9 10 ]
          shuffle _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret'].class).to eq(Array)
      expect(r['payload']['ret'].length).to eq(11)
      expect(r['payload']['ret'].sort).to eq((0..10).to_a)
    end

    it 'fails if there is no array to shuffle' do

      r = @executor.launch(
        %q{
          shuffle _
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('no array to shuffle')
    end

    it 'accepts a count for the sample size' do

      r = @executor.launch(
        %q{
          [ 0 1 2 3 4 5 6 7 8 9 10 ]
          shuffle 4
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret'].class).to eq(Array)
      expect(r['payload']['ret'].length).to eq(4)
    end

    it 'accepts a count: for the sample size' do

      r = @executor.launch(
        %q{
          [ 0 1 2 3 4 5 6 7 8 9 10 ]
          shuffle count: 5
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret'].class).to eq(Array)
      expect(r['payload']['ret'].length).to eq(5)
    end

    it 'accepts the array as argument' do

      r = @executor.launch(
        %q{
          shuffle [ 0 1 2 3 4 5 6 7 8 9 10 ] 4
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret'].class).to eq(Array)
      expect(r['payload']['ret'].length).to eq(4)
    end
  end

  describe 'sample' do

    it 'returns only one element of the array' do

      r = @executor.launch(
        %q{
          sample [ 0 1 2 3 4 5 6 7 8 9 10 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to be_between(-1, 11)
    end
  end
end

