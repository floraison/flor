
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
  end
end

