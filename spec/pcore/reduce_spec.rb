
#
# specifying flor
#
# Fri Nov 17 06:01:34 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'reduce' do

    it 'reduces with a func' do

      r = @executor.launch(
        %q{
          reduce [ '0', 1, 'b', 3 ]
            def r x
              r + x
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b3')
    end

    it 'reduces with a func and a start value' do

      r = @executor.launch(
        %q{
          reduce [ 0, 1, 2, 3 ] 7
            def r x \ r + x
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(13)
    end

    it 'reduces with a func and a start value' do

      r = @executor.launch(
        %q{
          reduce 7 [ 1, 2, 3, 4 ]
            def r x \ r + x
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(17)
    end

    it 'reduces with a proc' do

      r = @executor.launch(
        %q{
          reduce [ '0', 1, 'b', 3, '3f' ] v.+
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('01b33f')
    end

    it 'reduces with a proc and a start value' do

      r = @executor.launch(
        %q{
          reduce 4 [ 1, 2, 3 ] v.+
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(10)
    end

    context 'with objects' do

      it 'reduces' do

         r = @executor.launch(
           %q{
             reduce 4 { a: 1, b: 2, c: 3 }
               def r k v i \ r + v + i
           })

         expect(r['point']).to eq('terminated')
         expect(r['payload']['ret']).to eq(13)
      end
    end
  end
end

