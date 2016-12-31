
#
# specifying flor
#
# Wed Feb 24 10:48:15 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'apply' do

    it 'applies a function' do

      flor = %{
        sequence
          define sum a b
            +
              a
              b
          apply sum 1 2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end
  end
end

