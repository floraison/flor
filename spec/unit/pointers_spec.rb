
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

      wait_until { @unit.executions.by_tag('a').count == 2 }

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

      wait_until { @unit.executions.by_tasker('hole').count == 1 }

      exes = @unit.executions.by_tasker('hole')

      expect(exes.collect(&:exid)).to eq([ exid ])
    end

    it 'keeps the message and atts given to taskers' do

      r =
        @unit.launch(%{
          sequence
            set f.x 1
            set f.y 2
            hole task: 'cleanup', detail_level: { a: 1, b: 2 }
        }, wait: 'task')

      expect(r['point']).to eq('task')
      expect(r['nid']).to eq('0_2')

      exid = r['exid']

      ptr = wait_until { @unit.pointers.where(type: 'tasker').first }

      c = ptr.data
      m = c['message']
      a = c['atts']

      expect(m['point']).to eq('receive')
      expect(m['payload']).to eq('ret' => nil, 'x' => 1, 'y' => 2)

      expect(a).to eq([
        [ nil, "hole" ], [ "task", "cleanup" ],
        [ "detail_level", { "a"=>1, "b"=>2 } ] ])
    end

    it 'removes pointers to taskers when done' do

      r =
        @unit.launch(%{
          sequence
            alpha task: 'wipe table'
            stall _
        }, wait: '0_1 receive')

      expect(r['point']).to eq('receive')

      sleep 0.350

      expect(@unit.pointers.count).to eq(0)
    end

    it 'removes pointers to taskers when terminated' do

      r =
        @unit.launch(%{
          alpha task: 'wipe table'
        }, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.350

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

      wait_until { @unit.executions.by_var('item_id').count == 2 }

      exes = @unit.executions.by_var('item_id')

      expect(exes.collect(&:exid).sort).to eq([ i0, i1 ].sort)

      exes = @unit.executions.by_var('role_name', 'boss')

      expect(exes.collect(&:exid)).to eq([ i1 ])

      exes = @unit.executions.by_var('role_name', 'chief of staff')

      expect(exes.collect(&:exid)).to eq([])
    end

    it 'points to executions by var name and blank value' do

      r =
        @unit.launch(%{
          sequence
            set item_id null
            stall _
        }, wait: '0_1 execute')
      exid = r['exid']

      expect(r['point']).to eq('execute')
      expect(r['nid']).to eq('0_1')

      wait_until { @unit.executions.by_var('item_id').count == 1 }

      exes = @unit.executions.by_var('item_id')

      expect(exes.collect(&:exid)).to eq([ exid ])

      exes = @unit.executions.by_var('item_id', '')

      expect(exes.collect(&:exid)).to eq([ exid ])

      exes = @unit.executions.by_var('item_id', 1)

      expect(exes.collect(&:exid)).to eq([])
    end

    it 'removes pointers to terminated executions' do

      r =
        @unit.launch(%{
          sequence tag: 'a'
        }, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.350

      expect(@unit.pointers.count).to eq(0)
    end

    it 'does not insert too many pointers' do

      r =
        @unit.launch(%{
          concurrence
            hole task: 'a'
            alpha task: 'b'
            sequence
              sleep 1
              alpha task: 'c'
        }, wait: '0_2_1 task')

      expect(r['point']).to eq('task')

      sleep 0.350

      # use this one alone with `FLOR_DEBUG=db,dbg` and observe how
      # it avoids deleting and re-inserting pointers
    end
  end
end

