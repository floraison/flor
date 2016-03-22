
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

  describe '_key' do

    it 'sets the key string in its f.ret' do

      r = @executor.launch([ '_key', [ [ 'a', [], 1 ] ], 1 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('a')
    end
  end

  describe '_obj' do

    it 'works (single _)' do

      r = @executor.launch(%{ {} })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({})
    end

    it 'works' do

      r = @executor.launch(%{ { a: 'A' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'A' })
    end
  end
end

