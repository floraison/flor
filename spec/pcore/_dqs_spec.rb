
#
# specifying flor
#
# Sun Jul 22 16:01:08 JST 2018
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

    it 'works with strings with backslash escapes' do

      r = @executor.launch(%{ "abc\\ndef" })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq("abc\ndef")
    end

    it 'works with strings with backslash escapes for unicode characters'
  end
end

