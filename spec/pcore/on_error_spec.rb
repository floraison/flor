
#
# specifying flor
#
# Sun May  6 05:54:58 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'on_error' do

    context 'function' do

      it 'binds in the parent node' do

        @executor.launch(
          %q{
            sequence
              on_error (def err; _)
              stall _
          })

        expect(
          @executor.execution['nodes']['0']['on_error']
        ).to eq(
          [ [ '_func',
              { 'nid' => '0_0_0_0',
                'tree' => [ 'def', [ [ '_att', [ [ 'err', [], 3 ] ], 3 ] ], 3 ],
                'cnid' => '0',
                'fun' => 0,
                'on_error' => true },
              3 ] ]
        )
      end

      it 'triggers on error' do

        r = @executor.launch(
          %q{
            sequence
              on_error (def err \ push f.l err.error.msg)
              push f.l 0
              push f.l x
              push f.l 1
          },
          payload: { 'l' => [] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['l']).to eq([ 0, "don't know how to apply \"x\"" ])
      end
    end

    context 'block' do

      it 'binds in the parent node'
#
#        @executor.launch(
#          %q{
#            sequence
#              on_error
#                push f.l err
#              stall _
#          })
#
#        expect(
#          @executor.execution['nodes']['0']['on_error']
#        ).to eq(
#          [ [ '_func',
#              { 'nid' => '0_0_0_0_0',
#                'tree' => [ 'def', [ [ '_att', [ [ 'err', [], 3 ] ], 3 ] ], 3 ],
#                'cnid' => '0',
#                'fun' => 0,
#                'on_error' => true },
#              3 ] ]
#        )
#      end

      it 'triggers on error'
    end
  end
end

