
#
# specifying flor
#
# Sun Apr  3 14:11:49 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'match' do

    it 'returns false when it does not match' do

      rad = %{
        match "alpha" /bravo/
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'turns the second argument into a regular expression'
  end

  describe 'starts_with' do

    it 'works'
  end

  describe 'ends_with' do

    it 'works'
  end
end

