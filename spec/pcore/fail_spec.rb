
#
# specifying flor
#
# Thu Dec 15 06:27:45 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'fail' do

    it 'raises an error' do

      flor = %{
        fail 'not enough flour'
      }

      r = @executor.launch(flor)

      #pp r
      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('Flor::FlorError')
      expect(r['error']['msg']).to eq('not enough flour')
      expect(r['error']['lin']).to eq(2)
      expect(r['error']['trc']).to eq(nil)
    end

    it 'raises an error when empty too' do

      flor = %{
        fail _
      }

      r = @executor.launch(flor)

      #pp r
      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('Flor::FlorError')
      expect(r['error']['msg']).to eq('error')
      expect(r['error']['lin']).to eq(2)
      expect(r['error']['trc']).to eq(nil)
    end
  end

  describe 'error' do

    it 'is an alias to "fail"' do

      flor = %{
        error 'not enough water'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('not enough water')
    end
  end
end

