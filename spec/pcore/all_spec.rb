
#
# specifying flor
#
# Tue Jan 16 06:38:58 JST 2018  Jalan Senang
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'all?' do

    context 'with function' do

      it 'returns true if all the array elements match' do

        r = @executor.launch(
          %q{
            all? [ 1, 2, 3 ]
              def elt \ elt > 0
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if at least one array element does not match' do

        r = @executor.launch(
          %q{
            all? [ 1, 2, 3 ]
              def elt \ elt == 1
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end

      it 'returns true if all the object entries match' do

        r = @executor.launch(
          %q{
            all? { a: 'A', b: 'B' }
              def key, val \ val == 'A' or val == 'B'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if at least one object entry does not match' do

        r = @executor.launch(
          %q{
            all? { a: 'A', b: 'B', c: 'C' }
              def key, val \ val == 'A'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end

    context 'without function' do

      it 'returns true if all the array elements are trueish' do

        r = @executor.launch(
          %q{
            all? [ 1 2 3 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if at least an array element is not trueish' do

        r = @executor.launch(
          %q{
            all? [ 1 false 3 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end

      it 'returns true if the array is empty' do

        r = @executor.launch(
          %q{
            all? []
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns true if all the object values are trueish' do

        r = @executor.launch(
          %q{
            all? { a: 'A', b: 'B', c: 'C' }
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if at least one object value is not trueish' do

        r = @executor.launch(
          %q{
            all? { a: 'A', f: false, c: 'C' }
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end

      it 'returns true if the object is empty' do

        r = @executor.launch(
          %q{
            all? {}
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end
    end
  end
end

