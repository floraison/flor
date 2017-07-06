
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

  describe 'noret' do

    it 'leaves f.ret as is' do

      r = @executor.launch(
        %q{
          sequence
            1
            noret _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it "doesn't mind attributes and children" do

      r = @executor.launch(
        %q{
          2
          noret "hello"
          noret
            [ 1, 2, 3 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end
  end
end

