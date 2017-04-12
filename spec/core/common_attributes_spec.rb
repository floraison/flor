
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

      context 'array' do

        it 'whitelists'
        it 'whitelists with regexes'
        it 'blacklists'
        it 'blacklists with regexes'
      end

      context '"copy"' do

        it 'copies all the vars' do

          flor = %{
            sequence vars: { a: 'A' }
              push f.l [ 0 a ]
              sequence vars: 'copy'
                push f.l [ 1 a ]
                set a 'B'
                push f.l [ 2 a ]
              push f.l [ 3 a ]
          }

          r = @executor.launch(flor, payload: { 'l' => [] })

          expect(r['point']).to eq('terminated')

          expect(
            r['payload']['l']
          ).to eq(
            [ [ 0, 'A' ], [ 1, 'A' ], [ 2, 'B' ], [ 3, 'A' ] ]
          )
        end
      end

      context '"*"' do

        it 'copies all the vars' do

          flor = %{
            sequence vars: { a: 'A' }
              push f.l [ 0 a ]
              sequence vars: '*'
                push f.l [ 1 a ]
                set a 'B'
                push f.l [ 2 a ]
              push f.l [ 3 a ]
          }

          r = @executor.launch(flor, payload: { 'l' => [] })

          expect(r['point']).to eq('terminated')

          expect(
            r['payload']['l']
          ).to eq(
            [ [ 0, 'A' ], [ 1, 'A' ], [ 2, 'B' ], [ 3, 'A' ] ]
          )
        end
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

