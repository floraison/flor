
#
# specifying flor
#
# Sun Jul 22 16:01:45 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_rxs' do

    it 'builds a regular expression' do

      r = @executor.launch(%{ /hello world/i })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ '_rxs', '/hello world/i', 1 ])
    end

    it 'expands the expression' do

      r = @executor.launch(%{ /hello $(f.to)/i }, payload: { 'to' => 'mundo' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ '_rxs', '/hello mundo/i', 1 ])
    end
  end
end

