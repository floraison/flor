
#
# specifying flor
#
# Thu Jan 18 09:52:02 JST 2018  Asia Square
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'empty?' do

    context 'with nothing' do

      it 'leaves the previous ret untouched' do

        r = @executor.launch(
          %q{
            1
            empty? _
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(1)
      end
    end

    context 'with array' do

      it 'returns true when empty' do

        r = @executor.launch(
          %q{
            empty? []
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false when not empty' do

        r = @executor.launch(
          %q{
            empty? [ 1, 2, 3 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end

    context 'with object' do

      it 'returns true when empty' do

        r = @executor.launch(
          %q{
            empty? {}
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false when not empty' do

        r = @executor.launch(
          %q{
            empty? { a: 'A' }
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end

    context 'with strings' do

      it 'returns true when empty' do

        r = @executor.launch(
          %q{
            empty? ''
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false else' do

        r = @executor.launch(
          %q{
            empty? 'oh oh oh'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end

    context 'with null' do

      it 'returns true' do

        r = @executor.launch(
          %q{
            empty? null
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end
    end

    context 'else' do

      it 'returns false' do

        r = @executor.launch(
          %q{
            empty? 1
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end
  end
end

