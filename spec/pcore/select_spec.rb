
#
# specifying flor
#
# Thu Nov  9 07:19:25 JST 2017  Singapore
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'select' do

    it 'filters elements' do

      r = @executor.launch(
        %q{
          select [ 1, 2, 3, 4, 5 ]
            = (elt % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    it 'filters f.ret by default' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3, 4, 5 ]
          select
            = (elt % 2) 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    context 'with objects' do

      it 'returns an object with filtered entries' do

        r = @executor.launch(
          %q{
            select { a: 'A', b: 'B', c: 'C', d: 'D' }
              key == 'a' or val == 'C' or idx == 3
          })

        expect(r['point']
          ).to eq('terminated')
        expect(r['payload']['ret']
          ).to eq({ 'a' => 'A', 'c' => 'C', 'd' => 'D' })
      end
    end
  end

  describe 'reject' do

    it 'filters out elements' do

      r = @executor.launch(
        %q{
          reject [ 1, 2, 3, 4, 5 ]
            (elt % 2) == 0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 3, 5 ])
    end

    context 'with objects' do

      it 'returns an object with filtered entries' do

        r = @executor.launch(
          %q{
            reject { a: 'A', b: 'B', c: 'C', d: 'D' }
              key == 'a' or idx == 3
          })

        expect(r['point']
          ).to eq('terminated')
        expect(r['payload']['ret']
          ).to eq({ 'b' => 'B', 'c' => 'C' })
      end
    end
  end
end

