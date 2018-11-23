
#
# specifying flor
#
# Fri Nov 23 20:18:50 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'return' do

    it 'returns from its containing' do

      r = @executor.launch(%q{
        define f
          return 'b' if true
          'a'
        f _
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('b')
    end

    it 'fails if not in a function'
  end
end

