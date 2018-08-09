
#
# specifying flor
#
# Wed May 18 13:58:27 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

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

  describe 'cancelling a node' do

    it 'cancels a leaf node' do

      r = @unit.launch(%q{ stall _ }, wait: '0 receive')

      exid = r['exid']

      wait_until { @unit.executions[exid: exid] }

      xd = @unit.executions[exid: exid].data

      expect(xd['nodes'].keys).to eq(%w[ 0 ])

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => exid, 'nid' => '0' },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.executions.where(status: 'active').count < 1 }

      expect(
        @unit.executions.where(status: 'active').count
      ).to eq(0)
    end

    it 'cancels a node and its children' do

      exid = @unit.launch(
        %q{
          sequence
            sequence
              stall _
        },
        payload: { 'x' => 'y' })

      wait_until { @unit.executions[exid: exid] }

      xd = @unit.executions[exid: exid].data

      expect(xd['nodes'].keys).to eq(%w[ 0 0_0 0_0_0 ])

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => exid, 'nid' => '0_0' },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'x' => 'y' })

      wait_until { @unit.executions.where(status: 'active').count < 1 }

      expect(
        @unit.executions.where(status: 'active').count
      ).to eq(0)
    end

    it 'can force a new payload on the cancelled node' do

      r = @unit.launch(
        %q{
          sequence
            sequence
              stall _
        },
        payload: { 'x' => '0' },
        wait: '0_0_0 receive')

      exid = r['exid']

      r = @unit.queue(
        { 'point' => 'cancel',
          'exid' => exid, 'nid' => '0_0',
          'payload' => { 'x' => 1 } },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'x' => 1 })
    end
  end

  describe 'cancelling a non-existing node' do

    it 'has no effect' do

      exid =
        @unit.launch(
          %q{
            sequence
              sequence
                stall _
          }, wait: '0_0_0 receive'
        )['exid']

      wait_until { @unit.executions.first(exid: exid).data['nodes'].size > 2 }

      expect(
        @unit.executions.first(exid: exid).data['nodes'].keys
      ).to eq(%w[ 0 0_0 0_0_0 ])

      @unit.queue({
        'point' => 'cancel',
        'exid' => exid, 'nid' => '0_1',
        'payload' => {} })

      @unit.wait(exid, 'end')

      expect(
        @unit.executions.first(exid: exid).data['nodes'].keys
      ).to eq(%w[ 0 0_0 0_0_0 ])
    end
  end
end

