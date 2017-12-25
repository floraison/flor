
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

    it 'reduces with a func' do

      r = @executor.launch(
        %q{
          reduce [ '0', 1, 'b', 3 ]
            def r x
              r + x
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b3')
    end

    it 'reduces with a proc' do

      r = @executor.launch(
        %q{
          reduce [ '0', 1, 'b', 3, '3f' ] v.+
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b33f')
    end
  end
end

