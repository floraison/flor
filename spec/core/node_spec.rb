
#
# specifying flor
#
# Tue Mar 22 06:44:32 JST 2016
#

require 'spec_helper'


describe Flor::Node do

  describe '#lookup_tree' do

    context 'regular case' do

      it 'works' do

        execution = {
          'nodes' => {
            '0' => { 'tree' => [ 'sequence', [ [ 'a', [], 2 ] ], 1 ] },
            '0_1' => { 'parent' => '0' }
          }
        }
        node = Flor::Node.new(execution, nil, nil)

        expect(
          node.lookup_tree('0')
        ).to eq(
          [ 'sequence', [ [ 'a', [], 2 ] ], 1 ]
        )
        expect(
          node.lookup_tree('0_0')
        ).to eq(
          [ 'a', [], 2 ]
        )
      end
    end

    context 'node jump case' do

      it 'works' do

        execution = {
          'nodes' => {
            '0' =>
              { 'tree' =>
                [ 'sequence', [
                  [ 'concurrence', [
                    [ 'a', [], 3 ],
                    [ 'b', [], 4 ]
                  ], 2 ]
                ], 1 ] },
            '0_0_0' =>
              { 'parent' =>
                '0' }
          }
        }
        node = Flor::Node.new(execution, nil, nil)

        expect(
          node.lookup_tree('0')
        ).to eq(
          [ 'sequence', [
            [ 'concurrence', [
              [ 'a', [], 3 ], [ 'b', [], 4 ]
            ], 2 ]
          ], 1 ]
        )
        expect(
          node.lookup_tree('0_0_0')
        ).to eq(
          [ 'a', [], 3 ]
        )
      end
    end
  end
end

