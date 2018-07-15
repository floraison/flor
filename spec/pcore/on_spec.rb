
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
        ).to eq(
          [ [ '_func',
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
        )
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
        ).to eq(
          [ [ '_func',
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
        )
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

