
#
# specifying flor
#
# Sat Nov  4 07:44:28 JST 2017  広島空港
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'filter' do

    it 'filters elements' do

      r = @executor.launch(
        %q{
          filter [ 1, 2, 3, 4, 5 ]
            def x
              = (x % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    it 'filters f.ret by default' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3, 4, 5 ]
          filter
            def x \ = (x % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    context 'with objects' do

      it 'returns an object with filtered entries' do

        r = @executor.launch(
          %q{
            filter { a: 'A', b: 'B', c: 'C', d: 'D' }
              def k v i
                #or (k == 'a') (v == 'C') (i == 3)
                k == 'a' or v == 'C' or i == 3
          })

        expect(r['point']
          ).to eq('terminated')
        expect(r['payload']['ret']
          ).to eq({ 'a' => 'A', 'c' => 'C', 'd' => 'D' })
      end
    end
  end

  describe 'filter-out' do

    it 'filters out elements' do

      r = @executor.launch(
        %q{
          filter-out [ 1, 2, 3, 4, 5 ]
            def x
              = (x % 2) 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    context 'with objects' do

      it 'returns an object with filtered out entries' do

        r = @executor.launch(
          %q{
            filter-out { a: 'A', b: 'B', c: 'C', d: 'D' }
              def k v i \ k == 'a' or k == 'b'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq({ 'c' => 'C', 'd' => 'D' })
      end
    end
  end
end

