
#
# specifying flor
#
# Fri Nov 17 06:01:34 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'reduce' do

    it 'reduces' do

      r = @executor.launch(
        %q{
          reduce [ '0', 1, 'b', 3 ]
            def r x
              r + x
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b3')
    end

    it 'reduces' #do
#
#      r = @executor.launch(
#        %q{
#          reduce [ '0', 1, 'b', 3 ] +
#        })
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq('01b3')
#    end
  end
end

