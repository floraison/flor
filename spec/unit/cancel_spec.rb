
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

      flon = %{
        stall _
      }

      exid = @unit.launch(flon)

      sleep 0.350

      xd = @unit.executions[exid: exid].data

      expect(xd['nodes'].keys).to eq(%w[ 0 ])

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => exid, 'nid' => '0' },
        wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.1

      expect(
        @unit.executions.where(status: 'active').count
      ).to eq(0)
    end

    it 'cancels a node and its children' do

      flon = %{
        sequence
          sequence
            stall _
      }

      exid = @unit.launch(flon, payload: { 'x' => 'y' })

      sleep 0.350

      xd = @unit.executions[exid: exid].data

      expect(xd['nodes'].keys).to eq(%w[ 0 0_0 0_0_0 ])

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => exid, 'nid' => '0_0' },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'x' => 'y' })

      sleep 0.1

      expect(
        @unit.executions.where(status: 'active').count
      ).to eq(0)
    end

    it 'can force a new payload on the cancelled node' do

      flon = %{
        sequence
          sequence
            stall _
      }

      exid = @unit.launch(flon, payload: { 'x' => '0' })

      sleep 0.350

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

      flon = %{
        sequence
          sequence
            stall _
      }

      exid = @unit.launch(flon, wait: '0_0_0 receive')['exid']

      expect(
        @unit.executions.first(exid: exid).data['nodes'].keys
      ).to eq(%w[ 0 0_0 0_0_0 ])

      r = @unit.queue({
        'point' => 'cancel',
        'exid' => exid, 'nid' => '0_1',
        'payload' => {} })

      sleep 0.5

      expect(
        @unit.executions.first(exid: exid).data['nodes'].keys
      ).to eq(%w[ 0 0_0 0_0_0 ])
    end
  end
end

