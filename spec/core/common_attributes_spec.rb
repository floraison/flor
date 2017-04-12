
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

        flor = %{
          sequence vars: { a: 1 }
        }

        r = @executor.launch(flor)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(nil)
      end

      it 'sets vars locally' do

        flor = %{
          sequence vars: { a: 0 }
            push l [ a null ]
            sequence vars: { a: 1 b: 2 }
              push l [ a b ]
            push l [ a null ]
        }

        r = @executor.launch(flor, vars: { 'l' => [] })

        expect(r['point']).to eq('terminated')

        expect(
          r['vars']['l']
        ).to eq(
          [ [ 0, nil ], [ 1, 2 ], [ 0, nil ] ]
        )
      end
    end

    describe 'ret:' do

      it 'overrides f.ret' do

        flor = %{
          3 ret: 4
        }

        r = @executor.launch(flor)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(4)
      end
    end
  end
end

