
#
# specifying flor
#
# Wed May 31 05:14:14 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'length' do

    it 'returns the length of its argument' do

      r = @executor.launch(
        %q{
          [
            (length [ 'a' 'b' 'c' ])
            (length a0)
            (length a1)
            (length h0)
            #(length h0.a)
            #(length h0.b)
            ({ a: 'A', b: 'B'}; length _)
          ]
        },
        vars: { 'a0' => [], 'a1' => [ 1, 2 ], 'h0' => { 'a' => 0 } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 0, 2, 1, 2 ])
    end

    it 'fails if there are no argument with a length' do

      r = @executor.launch(
        %q{
          length _
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('ArgumentError')
      expect(r['error']['msg']).to eq('Found no argument that has a length')
    end

    it 'returns the length of the non-att argument' do

      r = @executor.launch(
        %q{
          length [ 0 1 2 ] tag: 'x'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end

    it 'returns the length of f.ret by default' do

      r = @executor.launch(
        %q{
          [ 0 1 2 ]
          length _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end

    it 'returns the length of f.ret by default (tag has no effect)' do

      r = @executor.launch(
        %q{
          [ 0 1 2 ]
          length tag: 'a'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end
  end
end

