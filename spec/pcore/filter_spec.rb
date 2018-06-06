
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

    it 'filters array elements' do

      r = @executor.launch(
        %q{
          filter [ 1, 2, 3, 4, 5 ]
            def x
              = (x % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    it 'filters object entries' do

      r = @executor.launch(
        %q{
          filter { a: 'A', b: 'B', c: 'C', d: 'D' }
            def k v i
              #or (k == 'a') (v == 'C') (i == 3)
              k == 'a' or v == 'C' or i == 3
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'a' => 'A', 'c' => 'C', 'd' => 'D' })
    end

    it 'filters the incoming ret (array) by default' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3, 4, 5 ]
          filter
            def x \ = (x % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    it 'filters the incoming ret (object) by default' do

      r = @executor.launch(
        %q{
          { a: 'A', b: 'B', c: 'C', d: 'D' }
          filter
            def k v i l
              i = (l - 1) or i = (l - 2)
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'c' => 'C', 'd' => 'D' })
    end

    it 'fails if not given a collection' do

      r = @executor.launch(
        %q{
          filter 1
            def k v i l
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('collection not given to "filter"')
    end

    it 'fails if not given a function' do

      r = @executor.launch(
        %q{
          filter [ 0 ]
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('function not given to "filter"')
    end
  end

  describe 'filter-out' do

    it 'filters out array elements' do

      r = @executor.launch(
        %q{
          filter-out [ 1, 2, 3, 4, 5 ]
            def x
              = (x % 2) 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    it 'filters out object entries' do

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

