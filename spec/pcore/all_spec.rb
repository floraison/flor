
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

    it 'returns true if all the elements match' do

      r = @executor.launch(
        %q{
          all? [ 1, 2, 3 ]
            def elt \ elt > 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'returns false if at least one element does not match' do

      r = @executor.launch(
        %q{
          all? [ 1, 2, 3 ]
            def elt \ elt == 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
    end

    context 'with objects' do

      it 'returns true if all the entries match' do

        r = @executor.launch(
          %q{
            all? { a: 'A', b: 'B' }
              def key, val \ val == 'A' or val == 'B'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end

      it 'returns false if at least one entry does not match' do

        r = @executor.launch(
          %q{
            all? { a: 'A', b: 'B', c: 'C' }
              def key, val \ val == 'A'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end
  end
end

