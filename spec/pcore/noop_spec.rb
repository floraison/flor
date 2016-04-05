
#
# specifying flor
#
# Wed Mar 23 17:40:35 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'noop' do

    it 'leaves f.ret as is' do

      rad = %{
        sequence
          1
          noop _
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end
  end
end

