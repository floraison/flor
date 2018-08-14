
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

    it 'accepts a count for the sample size' #do
#
#      r = @executor.launch(
#        %q{
#          [ 0 1 2 3 4 5 6 7 8 9 10 ]
#          shuffle 4
#        })
#
#      expect(r['point']).to eq('terminated')
#p r['payload']['ret']
#      expect(r['payload']['ret'].class).to eq(Array)
#      expect(r['payload']['ret'].length).to eq(11)
#    end
  end
end

