
#
# specifying flor
#
# Wed Nov 15 13:28:16 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'each' do

    it 'iterates over arrays' do

      r = @executor.launch(
        %q{
          set l []
          each [ 0 1 2 3 4 5 6 7 ]
            pushr l (2 * elt) if elt % 2 == 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'l' => [ 0, 4, 8, 12 ] })
      expect(r['payload']['ret']).to eq((0..7).to_a)
    end

    it 'iterates over objects' do

      r = @executor.launch(
        %q{
          set l []
          each { a: 'A', b: 'B', c: 'C' }
            pushr l (+ key val idx)
        })

      expect(r['point']
        ).to eq('terminated')
      expect(r['vars']
        ).to eq({ 'l' => %w[ aA0 bB1 cC2 ] })
      expect(r['payload']['ret']
        ).to eq({ 'a' => 'A', 'b' => 'B', 'c' => 'C' })
    end

    it 'iterates over the incoming ret object' do

      r = @executor.launch(
        %q{
          set l []
          { a: 'A', b: 'B', c: 'C' }
          each
            pushr l (+ key val idx)
        })

      expect(r['point']
        ).to eq('terminated')
      expect(r['vars']
        ).to eq({ 'l' => %w[ aA0 bB1 cC2 ] })
      expect(r['payload']['ret']
        ).to eq({ 'a' => 'A', 'b' => 'B', 'c' => 'C' })
    end
  end
end

