
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

  describe '_dqs' do

    it 'works with strings' do

      r = @executor.launch(%{ "abc def" })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('abc def')
    end
  end

  describe '_num' do

    it 'works with numbers' do

      r = @executor.launch(%{ 11 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 11 })
    end
  end
end

