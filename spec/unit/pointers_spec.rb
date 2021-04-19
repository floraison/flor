
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

      expect(ptr.attd).to eq({
        'detail_level' => { 'a' => 1, 'b' => 2 },
        'task' => 'cleanup' })
      expect(ptr.attl).to eq([
        'hole' ])
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

    # Trying to fight against DELETE FROM flor_pointers WHERE type = ' var '...
    # Not conclusive at all though.
    #
    it 'removes and re-inserts var pointers' do

      r =
        @unit.launch(%{
          set a 1
          set b 2
          set a 3
          stall _
        }, wait: '0_3 receive')

      expect(r['point']).to eq('receive')

      sleep 0.350

      vars = @unit.pointers.where(type: 'var').all

      expect(vars.collect { |v| [ v.name, v.value ] }
        ).to eq([ [ 'a', '3' ], [ 'b', '2' ] ])
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

    context 'errors' do

      it 'points to errors' do

        r =
          @unit.launch(%{
            concurrence
              hole task: 'a'
              fail 'nada'
          }, wait: true)

        expect(r['point']).to eq('failed')

        wait_until { @unit.pointers.count == 2 }

        fa = @unit.pointers.where(type: 'failure').first

        expect(fa.type).to eq('failure')
        expect(fa.name).to eq('Flor::FlorError l4')
        expect(fa.value).to eq('nada')
        expect(fa.data.keys.sort).to eq(%w[ error id nid ])
      end

      it 'is removed when the error is gone' do

        r =
          @unit.launch(%{
            sequence
              task 'bobo'
              task 'hole'
          }, wait: true)

        expect(r['point']).to eq('failed')

        wait_until {
          @unit.pointers.count == 2 }

        expect(
          @unit.pointers.reverse(:type).map([ :nid, :type, :name, :value ])
        ).to eq([
          [ '0_0', 'tasker', 'bobo', 'null' ],
          [ '0_0', 'failure', 'ArgumentError l', 'tasker "bobo" not found' ]
        ])

        @unit.kill(r['exid'], '0_0')

        wait_until {
          @unit.pointers.where(type: 'tasker', name: 'hole').count == 1 }

        expect(
          @unit.pointers.reverse(:type).map([ :nid, :type, :name, :value ])
        ).to eq([
          [ '0_1', 'tasker', 'hole', 'null' ],
        ])
      end
    end
  end

  describe Flor::Pointer do

    describe '#full_value' do

      it 'returns the expected info'
    end

    describe '#attd, #attl, and #att_texts' do

      it 'returns the expected info' do

        r =
          @unit.launch(%{
            concurrence
              hole 't0'
              hole task: 't1'
              hole task: 't2' title: 'title2'
              hole 't3' 'title3'
              hole 't4' 'title4' 44.44 { a: 4 }
          }, wait: '0_3 task')

        expect(r['point']).to eq('task')

        wait_until { @unit.pointers.where(type: 'tasker').count === 5 }

        ps = @unit.pointers.where(type: 'tasker').order(:ctime).all

        expect(ps[0].attd).to eq({})
        expect(ps[0].attl).to eq([ 'hole', 't0' ])
        expect(ps[0].att_texts).to eq([ 'hole', 't0' ])
        expect(ps[0].value).to eq('t0')

        expect(ps[1].attd).to eq({ 'task' => 't1' })
        expect(ps[1].attl).to eq([ 'hole' ])
        expect(ps[1].att_texts).to eq([ 'hole' ])
        expect(ps[1].value).to eq('t1')

        expect(ps[2].attd).to eq({ 'task' => 't2', 'title' => 'title2' })
        expect(ps[2].attl).to eq([ 'hole' ])
        expect(ps[2].att_texts).to eq([ 'hole' ])
        expect(ps[2].value).to eq('t2')

        expect(ps[3].attd).to eq({})
        expect(ps[3].attl).to eq([ 'hole', 't3', 'title3' ])
        expect(ps[3].att_texts).to eq([ 'hole', 't3', 'title3' ])
        expect(ps[3].value).to eq('t3')

#i = 4; p ps[i].attd; p ps[i].attl; p ps[i].att_texts; p ps[i].value
        expect(ps[4].attd).to eq({})
        expect(ps[4].attl).to eq([ 'hole', 't4', 'title4', 44.44, { 'a' => 4 } ])
        expect(ps[4].att_texts).to eq([ 'hole', 't4', 'title4' ])
        expect(ps[4].value).to eq('t4')
      end
    end
  end
end

