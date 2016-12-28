
#
# specifying flor
#
# Wed Dec 28 14:41:40 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  context 'common attributes' do

    describe 'vars:' do

      it 'does not set f.ret' do

        flon = %{
          sequence vars: { a: 1 }
        }

        r = @executor.launch(flon)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(nil)
      end
    end

    describe 'ret:' do

      it 'overrides f.ret' do

        flon = %{
          3 ret: 4
        }

        r = @executor.launch(flon)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(4)
      end
    end
  end
end

