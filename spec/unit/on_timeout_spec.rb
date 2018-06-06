
#
# specifying flor
#
# Tue May 29 13:38:03 JST 2018
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'the on_timeout: attribute' do

    it 'binds' do

      exid = @unit.launch(
        %q{
          sequence on_timeout: (def msg \ _)
            stall _
        })

      wait_until {
        @unit.journal
          .find { |m| m['point'] == 'receive' && m['nid'] == '0_1' } }

      expect(
        @unit.execution(exid)['nodes']['0']['on_timeout']
      ).to eq([
        [ '_func',
          {  'nid' => '0_0_1',
             'tree' => [
               'def', [
                 [ '_att', [ [ 'msg', [], 2 ] ], 2 ], [ '_', [], 2 ]
                ], 2],
             'cnid' => '0',
             'fun' => 0,
             'on_timeout' => true},
          2 ]
      ])
    end

    it 'runs the code after the last child has replied' do

      r = @unit.launch(
        %q{
          sequence timeout: '1s' on_timeout: (def msg \ push f.l "$(msg.point):$(msg.nid):$(msg.flavour)")
            push f.l 0
            stall _
          push f.l 1
        },
        payload: { 'l' => [] },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 'cancel:0_0:timeout', 1 ])
    end

    it 'favours the on_timeout:' do

      r = @unit.launch(
        %q{
          define oc msg
            push f.l "oc:$(msg.point):$(msg.nid):$(msg.flavour)"
          define oto msg
            push f.l "oto:$(msg.point):$(msg.nid):$(msg.flavour)"

          sequence timeout: '1s' on_cancel: oc on_timeout: oto
            push f.l 0
            stall _

          push f.l 1
        },
        payload: { 'l' => [] },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 'oto:cancel:0_2:timeout', 1 ])
    end

    it 'does not trigger if it is a regular cancel' do

      r = @unit.launch(
        %q{
          set l []

          define oto msg
            push l "oto:$(msg.point):$(msg.nid):$(msg.flavour)"

          sequence timeout: '1d' on_timeout: oto
            push l 0
            stall _

          push l 1
        },
        wait: 'end')

      expect(r['point']).to eq('end')

      @unit.cancel(exid: r['exid'], nid: '0_2', payload: {})

      r = @unit.wait(r['exid'], 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 1 ])
    end

    it 'does not trigger if it is a kill' do

      r = @unit.launch(
        %q{
          set l []

          define oto msg
            push l "oto:$(msg.point):$(msg.nid):$(msg.flavour)"

          sequence timeout: '1d' on_timeout: oto
            push l 0
            stall _

          push l 1
        },
        wait: 'end')

      expect(r['point']).to eq('end')

      @unit.kill(exid: r['exid'], nid: '0_2', payload: {})

      r = @unit.wait(r['exid'], 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 1 ])
    end

    it 'does not trigger for an upstream timeout' do

      r = @unit.launch(
        %q{
          set l []
          sequence timeout: '1s'
            sequence,
                on_timeout:
                  (def msg \ push l "$(msg.point):$(msg.nid):$(msg.flavour)")
              push l 0
              stall _
          push l 1
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 1 ])
    end
  end
end

