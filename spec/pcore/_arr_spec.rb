
#
# specifying flor
#
# Fri Feb 26 11:48:09 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_arr' do

    it 'builds an empty array' do

      r = @executor.launch(%{ [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([])
    end

    it 'builds an array' do

      r = @executor.launch(%{ [ 1, 2, "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'trois' ])
    end

    it 'builds an array (without commas)' do

      r = @executor.launch(%{ [ 1 2 "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'trois' ])
    end

    it 'builds an array (with commas)' do

      r = @executor.launch(%{ [ 1, 2,, 4 ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 4 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [
          1
          2
        ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [ 1
          2 ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [ 1
          (2 _) ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with vars)' do

      r = @executor.launch(%{
        set b 2
        [ 1 b "c" * b, "d_$(b)" ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'cc', 'd_2' ])
    end
  end
end

