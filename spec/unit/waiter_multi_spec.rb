
#
# specifying flor
#
# Thu Mar  7 21:39:17 JST 2019
#

require 'spec_helper'


describe Flor::Waiter do

  context 'waiting for another unit' do

    before :each do

      # @unit0 is the processing unit
      # @unit1 is used for reading and launching

      sto_uri = RUBY_PLATFORM.match(/java/) ?
        'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

      @unit0 = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
      @unit0.conf['unit'] = 'xu0'
      @unit0.storage.delete_tables
      @unit0.storage.migrate
      @unit0.hook('journal', Flor::Journal)
      @unit0.start

      @unit1 = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
      @unit1.conf['unit'] = 'xu1'
      @unit1.hook('journal', Flor::Journal)
      #@unit1.start # no, no starting

      #2.times { Thread.pass }
      sleep 0.350
    end

    after :each do

      @unit0.shutdown
      @unit1.shutdown
    end

    it 'rejects msg waiters in non-started units' do

      expect {
        @unit1.launch(%q{ + 1 2 }, wait: 'terminated')
      }.to raise_error(
        ArgumentError, /\Aunit is stopped, it cannot wait for \["domain0/
      )
    end

    it 'rejects row waiters if there are already msg waiters' do

      Thread.new do
        begin
          @unit0.launch(%q{ stall _ }, wait: 'terminated')
        #rescue => err; puts "!" * 80; p err; end
        rescue; end
      end

      sleep 0.140

      expect {
        @unit0.wait(nil, 'status:terminated')
      }.to raise_error(
        ArgumentError,
        'cannot add a row waiter, since there are already msg ones'
      )
    end

    it 'rejects msg waiters if there are already row waiters' do

      Thread.new do
        begin
          @unit0.launch(%q{ stall _ }, wait: 'status:terminated')
        #rescue => err; puts "!" * 80; p err; end
        rescue; end
      end

      sleep 0.140

      expect {
        @unit0.wait(nil, 'terminated')
      }.to raise_error(
        ArgumentError,
        'cannot add a msg waiter, since there are already row ones'
      )
    end

    it 'launches in unit1 and processes in unit0' do

      exid = @unit1.launch(
        %q{
          + 1 2 3
        })

      wait_until(21) do
        @unit0.journal.count > 0
      end
      wait_until(21) do
        exe = @unit1.storage.executions[exid: exid]
        exe && exe.status == 'terminated'
      end

      expect(@unit0.journal.count).to eq(10)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)

      exe = @unit1.storage.executions.first

      expect(
        exe.closing_messages.collect { |m| m['point'] }
      ).to eq(
        %w[ terminated ]
      )
    end

    it 'lets the launcher wait for an execution termination' do

      exe = @unit1.launch(
        %q{
          + 1 2 3
        },
        wait: 'status:terminated')

      wait_until(21) { @unit0.journal.count >= 10 }

      expect(@unit0.journal.count).to eq(10)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)

      expect(exe.status).to eq('terminated')
      expect(exe.closing_messages.first['payload']).to eq('ret' => 6)
    end

    it 'lets the launcher wait for the presence of a tag' do

      ptr = @unit1.launch(
        %q{
          1
          sequence tag: 'alpha'
            stall _
        },
        wait: 'tag:alpha')

      wait_until(21) { @unit0.journal.count >= 15 }

      expect(@unit0.journal.count).to eq(15)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)
      expect(@unit1.storage.executions.first.status).to eq('active')

      expect(ptr.type).to eq('tag')
      expect(ptr.name).to eq('alpha')
      #expect(ptr.data).to eq('xxx') # TODO maybe
    end

    it 'lets the launcher wait for the presence of a task' do

      @unit0.add_tasker('hole') {}

      ptr = @unit1.launch(
        %q{
          hole _
        },
        payload: { target: 'Talos IV' },
        wait: 'tasker:hole')

      wait_until(21) { @unit0.journal.count >= 9 }

      expect(@unit0.journal.count).to eq(9)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)
      expect(@unit1.storage.executions.first.status).to eq('active')

      expect(ptr.domain).to eq('domain0')
      expect(ptr.nid).to eq('0')
      expect(ptr.type).to eq('tasker')
      expect(ptr.name).to eq('hole')
      expect(ptr.payload).to eq('target' => 'Talos IV')
    end

    it 'lets the launcher wait for the presence of a task at a nid' do

      @unit0.add_tasker('hole') {}

      ptr = @unit1.launch(
        %q{
          concurrence
            hole 'take 1'
            hole 'take 2'
        },
        wait: '0_1 tasker:hole')

      wait_until(21) { @unit0.journal.count >= 22 }

      expect(@unit0.journal.count).to eq(22)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)
      expect(@unit1.storage.executions.first.status).to eq('active')

      expect(ptr.domain).to eq('domain0')
      expect(ptr.nid).to eq('0_1')
      expect(ptr.type).to eq('tasker')
      expect(ptr.name).to eq('hole')
      expect(ptr.value).to eq('take 2')
      expect(ptr.payload).to eq({})
    end

    it 'lets the launcher wait for two taskers' do

      @unit0.add_tasker('hole') {}

      ptr = @unit1.launch(
        %q{
          concurrence
            hole 'take 1'
            hole 'take 2'
        },
        wait: '0_0 tasker:hole; 0_1 tasker:hole')

      expect(ptr.nid).to eq('0_1')
      expect(ptr.type).to eq('tasker')
      expect(ptr.name).to eq('hole')
      expect(ptr.value).to eq('take 2')
    end

    it 'lets the launcher wait for a variable' do

      ptr = @unit1.launch(
        %q{
          set a 0
          set b 1
          set c 2
          stall _
        },
        wait: 'var:b; variable:c')

      expect(ptr.nid).to eq('0')
        # pointers only care about variables at node "0" (root)

      expect(ptr.type).to eq('var')
      expect(ptr.name).to eq('c')
      expect(ptr.value).to eq('2')
    end

    it 'lets the launcher wait for a variable and a given value' do

      ptr = @unit1.launch(
        %q{
          set a 0
          set b 1
          set c 'deux'
          stall _
        },
        wait: 'var:b; variable:c:deux')

      expect(ptr.nid).to eq('0')
        # pointers only care about variables at node "0" (root)

      expect(ptr.type).to eq('var')
      expect(ptr.name).to eq('c')
      expect(ptr.value).to eq('deux')
    end

    it 'lets the launcher wait for a variable (#full_value)' do

      ptr = @unit1.launch(
        %q{
          set a 0
          set b { age: 12, role: 'captain' }
          stall _
        },
        wait: 'var:b')

      expect(ptr.nid).to eq('0')
        # pointers only care about variables at node "0" (root)

      expect(ptr.type).to eq('var')
      expect(ptr.name).to eq('b')
      expect(ptr.value).to eq('(object)')
      expect(ptr.full_value).to eq({ 'age' => 12, 'role' => 'captain' })
    end
  end
end

