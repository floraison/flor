
#
# specifying flor
#
# Mon May 28 06:18:46 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'on_cancel' do

    it 'binds in the parent node' do

      @executor.launch(
        %q{
          sequence
            on_cancel (def msg \ _)
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
                  [ '_att', [ [ 'msg', [], 3 ] ], 3 ], [ '_', [], 3 ] ], 3],
              'cnid' => '0',
              'fun' => 0,
              'on_cancel' => true },
            3 ] ]
      ])
    end

    it 'triggers on (internal) cancel' do

      r = @executor.launch(
        %q{
          sequence
            on_cancel (def msg \ push f.l "$(msg.point):$(msg.nid)")
            push f.l 0
            cancel '0_0'
            push f.l 1
          push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 'cancel:0_0', 2 ])
    end

    it 'triggers on (external) cancel' do

      r = @executor.launch(
        %q{
          sequence
            on_cancel (def msg \ push f.l "$(msg.point):$(msg.nid)")
            push f.l 0
            stall _
            push f.l 1
          push f.l 2
        },
        payload: { 'l' => [] })

      expect(r).to eq(nil)

      m = @executor.walk([
        { 'point' => 'cancel',
          'nid' => '0_0', 'exid' => @executor.exid,
          'payload' => { 'l' => [ 'c' ] } } ])

      expect(m['point']).to eq('terminated')
      expect(m['nid']).to eq(nil)
      expect(m['payload']['l']).to eq([ 'c', 'cancel:0_0', 2 ])

      expect(m['cause'].size).to eq(1)
      expect(m['cause'][0]['m']).to eq(20)
      expect(m['cause'][0]['nid']).to eq('0_0')
      expect(m['cause'][0]['type']).to eq(nil)
    end
  end
end

