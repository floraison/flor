
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

      r = @executor.launch(
        %q{
          fail 'not enough flour'
        })

#pp r
      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('Flor::FlorError')
      expect(r['error']['msg']).to eq('not enough flour')
      expect(r['error']['lin']).to eq(2)
      expect(r['error']['trc']).to eq(nil)
    end

    it 'raises an error when empty too' do

      r = @executor.launch(
        %q{
          fail _
        })

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

      r = @executor.launch(
        %q{
          error 'not enough water'
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('not enough water')
    end
  end
end

