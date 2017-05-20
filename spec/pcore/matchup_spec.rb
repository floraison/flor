
#
# specifying flor
#
# Sun May 21 06:08:33 JST 2017  la maison de l'est
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'matchup' do

    it 'returns immediately if empty' do

      r = @executor.launch(
        %q{
          matchup _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'returns null when there is no match' do

      r = @executor.launch(
        %q{
          matchup 7 5
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'returns {} when there is a match (but no binding)' do

      r = @executor.launch(
        %q{
          matchup 7 7
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({})
    end
  end
end

