
#
# specifying flor
#
# Tue Dec 20 16:52:02 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'on_timeout' do

    it 'sets a timeout handler in its parent' do

      r = @unit.launch(
        %q{
          sequence
            on_timeout (def msg \ push f.l msg)
            stall _
        },
        wait: '0_1 receive')

      exe = wait_until { @unit.executions.first(exid: r['exid']) }

      expect(
        exe.data['nodes']['0']['on_timeout']
      ).to eq(
        [ [ '_func',
            { 'nid' => '0_0_0',
              'tree' => [
                'def', [
                  [ '_att', [ [ 'msg', [], 3 ] ], 3 ],
                  [ 'push', [
                    [ '_att', [ [ 'f.l', [], 3 ] ], 3 ],
                    [ '_att', [ [ 'msg', [], 3 ] ], 3 ] ], 3 ] ], 3 ],
              'cnid' => '0',
              'fun' => 0,
              'on_timeout' => true },
            3 ] ]
      )
    end

    it 'catches triggers on timeout' do

      r = @unit.launch(
        %q{
          set l []
          sequence timeout: '1s'
            push l 0
            on_timeout (def msg \ push l "$(msg.point):$(msg.nid)")
            stall _
            push l 2
          push l 3
        },
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 'cancel:0_1', 3 ])
    end
  end
end

