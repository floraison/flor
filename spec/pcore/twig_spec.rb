
#
# specifying flor
#
# Tue Mar  7 20:19:09 JST 2017  Koi Naka
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'twig' do

    it 'stores a tree in a variable' do

      r = @executor.launch(
        %q{
          twig a
            sequence \ 1; 2
        })

      expect(r['point']).to eq('terminated')

      expect(r['vars']['a']).to eq(
        [ 'sequence', [ [ '_num', 1, 3 ], [ '_num', 2, 3 ] ], 3 ])
    end

    it 'stores a tree in a variable (keyed att in the way)' do

      r = @executor.launch(
        %q{
          twig tag: 'bravo' a
            sequence \ 1; 2
        })

      expect(r['point']).to eq('terminated')

      expect(r['vars']['a']).to eq(
        [ 'sequence', [ [ '_num', 1, 3 ], [ '_num', 2, 3 ] ], 3 ])
    end

    it 'stores in a field' do

      r = @executor.launch(
        %q{
          twig f.subtree what: 'ever'
            sequence \ 1; 2
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['subtree']).to eq(
        [ 'sequence', [ [ '_num', 1, 3 ], [ '_num', 2, 3 ] ], 3 ])
    end

    it 'stores as payload.ret' do

      r = @executor.launch(
        %q{
          twig tag: 'bravo'
            sequence \ 1; 2
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq(
        [ 'sequence', [ [ '_num', 1, 3 ], [ '_num', 2, 3 ] ], 3 ])
    end
  end
end

