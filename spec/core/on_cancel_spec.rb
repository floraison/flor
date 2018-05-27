
#
# specifying flor
#
# Mon May  7 06:25:31 JST 2018
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'the on_cancel: attribute' do

    it 'binds' do

      @executor.launch(
        %q{
          sequence on_cancel: (def msg \ _)
            stall _
        })

      expect(
        @executor.execution['nodes']['0']['on_cancel']
      ).to eq([
        [ '_func',
          {  'nid' => '0_0_1',
             'tree' => [
               'def', [
                 [ '_att', [ [ 'msg', [], 2 ] ], 2 ], [ '_', [], 2 ]
                ], 2],
             'cnid' => '0',
             'fun' => 0,
             'on_cancel' => true},
          2]
      ])
    end

    it 'runs the code after the last child has replied' do

      r = @executor.launch(
        %q{
          sequence on_cancel: (def msg \ push f.l "$(msg.point):$(msg.nid)")
            push f.l 0
            cancel '0_0'
          push f.l 1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 'cancel:0_0', 1 ])
    end

    it 'runs when the cancel comes from above' do

      flon = %q{
        sequence
          push f.l 0
          sequence on_cancel: (def msg \ push f.l "$(msg.point):$(msg.nid)")
            push f.l 1
            stall _
          push f.l 3
      }

      ms = @executor.launch(
        flon, payload: { 'l' => [] }, until: '0_1_2 execute')
      m = ms.first

      expect(ms.size).to eq(1)
      expect(m['point']).to eq('execute')
      expect(m['payload']['l']).to eq([ 0, 1 ])

      m = @executor.walk([
        { 'point' => 'cancel',
          'nid' => '0', 'exid' => @executor.exid,
          'payload' => { 'l' => [] } } ])

      expect(m).not_to eq(nil)
      expect(m['point']).to eq('terminated')
      expect(m['payload']['l']).to eq([ 'cancel:0_1' ])
    end

    it 'is disregarded if the cancel is a "kill"'
  end
end

