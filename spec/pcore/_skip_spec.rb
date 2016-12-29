
#
# specifying flor
#
# Thu Dec 29 10:43:44 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_skip' do

    it 'skips a few messages' do

      flon = %{
        123
        _skip 7
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(123)

      expect(@executor.journal.size).to eq(18)
    end
  end
end

