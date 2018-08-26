
#
# specifying flor
#
# Sun May  6 16:43:25 JST 2018
#

require 'spec_helper'


describe 'Flor pcore' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'on' do

    context 'error' do

      it 'sets an error handler in its parent' do

        @executor.launch(
          %q{
            sequence
              on error
                push f.l err.msg
              stall _
          })

        expect(
          @executor.execution['nodes']['0']['on_error']
        ).to eq([
          [ [ '*' ],
            [ '_func',
              { 'nid' => '0_0_0',
                'tree' => [
                  'def', [
                    [ '_att', [ [ 'msg', [], 3 ] ], 3 ],
                    [ '_att', [ [ 'err', [], 3 ] ], 3 ],
                    [ 'push', [
                      [ '_att', [
                        [ '_ref', [
                          [ '_sqs', 'f', 4 ], [ '_sqs', 'l', 4 ],
                        ], 4 ]
                      ], 4 ],
                      [ '_att', [
                        [ '_ref', [
                          [ '_sqs', 'err', 4 ], [ '_sqs', 'msg', 4 ],
                        ], 4 ]
                      ], 4 ] ], 4 ] ], 3 ],
                'cnid' => '0',
                'fun' => 0,
                'on_error' => true },
              3 ] ]
        ])
      end

      it 'catches errors' do

        r = @executor.launch(
          %q{
            sequence
              push f.l 0
              on error
                push f.l msg.nid
                push f.l err.msg
              push f.l x
              push f.l 1
          },
          payload: { 'l' => [] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['l']
        ).to eq([ 0, '0_2_1', 'don\'t know how to apply "x"' ])
      end

      it 'works in conjunction with a cursor' do

        r = @executor.launch(
          %q{
            set f.l [ 'a' ]
            cursor
              on error
                continue _
              push f.l 'b'
              fail 'badly' if (length f.l) < 3
          })

        expect(r).not_to eq(nil)
        expect(r['point']).to eq('terminated')
        expect(r['payload']['l']).to eq([ 'a', 'b', 'b' ])
      end

      it 'works in conjunction with a cursor (2)' do

        r = @executor.launch(
          %q{
            set f.l [ 'a' ]
            cursor
              push f.l 'b'
              sequence on_error: (def msg \ continue _)
                fail 'badly' if (length f.l) < 3
          })

        expect(r).not_to eq(nil)
        expect(r['point']).to eq('terminated')
        expect(r['payload']['l']).to eq([ 'a', 'b', 'b' ])
      end

      it 'accepts criteria' do

        @executor.launch(
          %q{
            sequence
              set f.l []
              on error class: 'FlorError'
                push f.l [ msg.nid err.msg ]
              stall _
          })

        node0 = @executor.execution['nodes']['0']

        expect(
          node0['on_error']
        ).to eq([
          [ [ [ 'class', 'FlorError', 4 ] ],
            [ '_func',
              { 'nid' => '0_1_1',
                'tree' =>
                 [ 'def', [
                   [ '_att', [ [ 'msg', [], 4 ] ], 4 ],
                   [ '_att', [ [ 'err', [], 4 ] ], 4 ],
                   [ 'push', [ [ '_att', [
                     [ '_ref', [
                       [ '_sqs', 'f', 5 ],
                       [ '_sqs', 'l', 5 ]
                     ], 5 ]
                   ], 5 ],
                   [ '_att', [
                     [ '_arr', [
                        [ '_ref', [
                          [ '_sqs', 'msg', 5 ], [ '_sqs', 'nid', 5 ]
                        ], 5 ],
                        [ '_ref', [
                          [ '_sqs', 'err', 5 ], [ '_sqs', 'msg', 5 ]
                        ], 5 ]
                     ], 5 ]
                   ], 5 ]
                 ], 5 ] ],
                4],
                'cnid' => '0',
                'fun' => 0,
                'on_error' => true},
             4 ] ]
        ])
      end
    end

    context 'cancel' do

      it 'sets a cancel handler in its parent' do

        @executor.launch(
          %q{
            sequence
              on cancel
                push f.l msg
              stall _
          })

        expect(
          @executor.execution['nodes']['0']['on_cancel']
        ).to eq([
          [ [ '*' ],
            [ '_func',
              { 'nid' => '0_0_0',
                'tree' => [
                  'def', [
                    [ '_att', [ [ 'msg', [], 3 ] ], 3 ],
                    [ 'push', [
                      [ '_att', [
                        [ '_ref', [
                          [ '_sqs', 'f', 4 ], [ '_sqs', 'l', 4 ]
                        ], 4 ]
                      ], 4 ],
                      [ '_att', [ [ 'msg', [], 4 ] ], 4 ] ], 4 ] ], 3 ],
                'cnid' => '0',
                'fun' => 0,
                'on_cancel' => true },
              3 ] ]
        ])
      end

      it 'catches cancels' do

        r = @executor.launch(
          %q{
            sequence
              push f.l 0
              on cancel
                push f.l "$(msg.point):$(msg.nid)"
              cancel '0_0'
            push f.l 3
          },
          payload: { 'l' => [] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['l']).to eq([ 0, 'cancel:0_0', 3 ])
      end
    end

    context 'timeout' do

      # see spec/punit/on_spec.rb
    end
  end
end

