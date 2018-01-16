
#
# specifying flor
#
# Sat Jan 13 09:26:35 JST 2018  広島空港
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'any?' do

    it 'returns true if it finds a matching entry' do

      r = @executor.launch(
        %q{
          any? [ 1, 2, 3 ]
            def elt
              (elt % 2) == 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'returns false if it does not find a matching entry' do

      r = @executor.launch(
        %q{
          any? [ 1, 2, 3 ]
            def elt \ elt == 4
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
    end

    context 'no function' do

      it 'returns false if the array is empty' do

        r = @executor.launch(
          %q{
            any? []
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end

      it 'returns true if the array is not empty' do

        r = @executor.launch(
          %q{
            any? [ 'a' 1 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end
    end

    context 'with objects' do

      it 'returns true if it finds a matching entry' do

        r = @executor.launch(
          %q{
            any? { a: 'A', b: 'B', c: 'C' }
              def key, val
                val == 'B'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if it does not find a matching entry' do

        r = @executor.launch(
          %q{
            any? { a: 'A', b: 'B', c: 'C' }
              def key, val
                val == 'Z'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end

      context 'no function' do

        it 'returns false if the object is empty' do

          r = @executor.launch(
            %q{
              any? {}
            })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(false)
        end

        it 'returns true if the object is not empty' do

          r = @executor.launch(
            %q{
              any? { a: 'A' }
            })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(true)
        end
      end
    end
  end
end

