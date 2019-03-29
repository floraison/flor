
#
# specifying flor
#
# Fri Mar 15 16:57:18 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'addbranch'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    system('rm -f tmp/pile/task__*.json')
  end

  after :each do

    @unit.shutdown
  end

  describe '#add_branch' do

    it 'fails immediately if overshooting' do

      r = @unit.launch(
        %q{
          sequence
            stall _
        },
        wait: 'end')

      expect {

        @unit.add_branch(
          exid: r['exid'],
          nid: '0_5',
          tree: %q{ bob 'do important job' })

      }.to raise_error(
        ArgumentError,
        "target 0_5 is off by 4, node 0 has 1 branch"
      )
    end

    it 'fails immediately if the target node is past' do

      r = @unit.launch(
        %q{
          sequence
            india _
            india _
            stall _
        },
        wait: 'task;task;end;end')

      expect {

        @unit.add_branch(
          exid: r['exid'],
          nid: '0_1',
          tree: %q{ bob 'do important job' })

      }.to raise_error(
        ArgumentError,
        "target 0_1 too low, execution has already reached 0_2"
      )
    end

    it 'fails if :tree is missing' do

      #r = @unit.launch(
      #  %q{
      #    sequence
      #      stall _
      #  },
      #  wait: 'end')

      expect {
        #@unit.add_branch(exid: r['exid'], nid: '0_1') # no :tree
        @unit.add_branch(exid: 'nada-123', nid: '0_1') # no :tree
      }.to raise_error(
        ArgumentError, "missing trees: or tree:"
      )
    end

    #
    # pnid: parent nid, appending...
    # nid: nid, inserting...

    it 'works appending to a "sequence" (pnid:)' do

      r = @unit.launch(
        %q{
          sequence
            stall _
        },
        wait: 'end')

      @unit.add_branch(
        exid: r['exid'],
        pnid: '0',
        tree: %q{ alpha 'do important job' })

      @unit.cancel(exid: r['exid'], nid: '0_0')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r['payload']['ret']).to eq('do important job')
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['m']).to eq(22)
    end

    it 'works inserting at the end of a "sequence" (nid:)' do

      r = @unit.launch(
        %q{
          sequence
            stall _
        },
        wait: 'end')

      @unit.add_branch(
        exid: r['exid'],
        nid: '0_1',
        tree: %q{ alpha 'do important job' })

      @unit.cancel(exid: r['exid'], nid: '0_0')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r['payload']['ret']).to eq('do important job')
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['m']).to eq(22)
    end

    it 'works inserting in a "sequence" (nid:)' do

      r = @unit.launch(
        %q{
          sequence
            stall _
            alpha 'one'
        },
        wait: 'end')

      @unit.add_branch(
        exid: r['exid'],
        nid: '0_1',
        tree: %q{ alpha 'two' })

      @unit.cancel(exid: r['exid'], nid: '0_0')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r['payload']['ret']).to eq('one')
      expect(r['payload']['seen'].collect { |e| e[1] }).to eq(%w[ two one ])
      expect(r['m']).to eq(35)
    end

    it 'works appending to a "concurrence"' do

      exid = @unit.launch(
        %q{
          concurrence
            pile 'a'
            pile 'b'
        },
        payload: { 'age' => 88 })

      wait_until { Dir['tmp/pile/task__*.json'].size == 2 }
      sleep 0.350 # give execution time to settle

      @unit.add_branch(
        exid: exid,
        pnid: '0',
        tree: %q{ pile 'c' },
        payload: { age: 77 })

      wait_until { Dir['tmp/pile/task__*.json'].size == 3 }
      sleep 0.350 # give tasker time to write files

      task = JSON.parse(File.read(Dir['tmp/pile/task_*_0_2.json'].first))

      expect(task['payload']['age']).to eq(77)
    end
  end
end

