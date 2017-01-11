
#
# specifying flor
#
# Wed Jan 11 13:47:07 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

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

  describe 'the pointers table' do

    it 'points to executions by tag name' do

      r =
        @unit.launch(%{
          concurrence
            stall tag: 'a'
            stall tag: 'b'
        }, wait: '0_1 entered')
      i0 = r['exid']
      expect(r['point']).to eq('entered')

      r =
        @unit.launch(%{
          concurrence
            stall tag: 'a'
            stall tag: 'c'
        }, wait: '0_1 entered')
      i1 = r['exid']
      expect(r['point']).to eq('entered')

      sleep 0.350

      exes = @unit.executions.by_tag('a')

      expect(exes.collect(&:exid).sort).to eq([ i0, i1 ].sort)
    end

    it 'points to executions by task name'

    it 'points to executions by tasker name' do

      r =
        @unit.launch(%{
          sequence
            hole task: 'cleanup'
        }, wait: '0_0 task')
      exid = r['exid']

      expect(r['point']).to eq('task')

      sleep 0.350

      exes = @unit.executions.by_tasker('hole')

      expect(exes.collect(&:exid)).to eq([ exid ])
    end

    it 'removes pointers to taskers when done' do

      r =
        @unit.launch(%{
          alpha task: 'wipe table'
        }, wait: true)
      exid = r['exid']

      expect(r['point']).to eq('terminated')

      expect(@unit.pointers.count).to eq(0)
    end

    it 'points to executions by var name (and value)' do

      r =
        @unit.launch(%{
          sequence
            set item_id 1234
            set role_name 'procrastinator'
            stall _
        }, wait: '0 execute')
      i0 = r['exid']

      r =
        @unit.launch(%{
          sequence
            set item_id 1234
            set role_name 'boss'
            stall _
        }, wait: '0_2 execute')
      i1 = r['exid']

      sleep 0.350

      exes = @unit.executions.by_var('item_id')

      expect(exes.collect(&:exid).sort).to eq([ i0, i1 ].sort)

      exes = @unit.executions.by_var('role_name', 'boss')

      expect(exes.collect(&:exid)).to eq([ i1 ])

      exes = @unit.executions.by_var('role_name', 'chief of staff')

      expect(exes.collect(&:exid)).to eq([])
    end

    it 'points to executions by var name and nil value' do

      r =
        @unit.launch(%{
          sequence
            set item_id null
            stall _
        }, wait: '0_1 execute')
      exid = r['exid']

      expect(r['point']).to eq('execute')
      expect(r['nid']).to eq('0_1')

      sleep 0.350

      exes = @unit.executions.by_var('item_id')

      expect(exes.collect(&:exid)).to eq([ exid ])

      exes = @unit.executions.by_var('item_id', nil)

      expect(exes.collect(&:exid)).to eq([ exid ])

      exes = @unit.executions.by_var('item_id', 1)

      expect(exes.collect(&:exid)).to eq([])
    end

    it 'removes pointers to terminated executions' do

      r =
        @unit.launch(%{
          sequence tag: 'a'
        }, wait: true)
      exid = r['exid']

      expect(r['point']).to eq('terminated')

      expect(@unit.pointers.count).to eq(0)
    end
  end
end

