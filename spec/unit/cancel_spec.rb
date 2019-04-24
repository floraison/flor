
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

      expect(r).to have_terminated_as_point

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

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point
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

  describe 'cancelling a parent node or above' do

    it 'works for a simple sequence' do

      r = @unit.launch(
        %q{
          push f.l 0
          sequence
            push f.l 1
            cancel '0_1'
            push f.l 2
          push f.l 3
          'over'
        },
        payload: { 'l' => [] },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq('over')
      expect(r['payload']['l']).to eq([ 0, 1, 3 ])
    end

    it 'does not bite its tail' do

      r = @unit.launch(
        %q{
          push f.l 0
          cursor
            push f.l 1
            stall on_cancel: (def \ break 'breaking...')
            push f.l 2
          push f.l 3
        },
        payload: { 'l' => [] },
        wait: 'end')

      @unit.cancel(r['exid'], '0_1_1')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq('breaking...')
      expect(r['payload']['l']).to eq([ 0, 1, 3 ])
    end
  end
end

describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'ucapnoa'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'cancelling a parent node or above' do

    it 'does not bite its tail (task)' do # gh-26

      @unit.add_tasker(
        'alice',
        class SpucAliceTasker < Flor::BasicTasker
          def on_task
#p :task!
            []
          end
          def on_detask
#p :detask!
            payload['l'] << "dt_m#{message['m']}"
            reply
          end
          self
        end)

      r = @unit.launch(
        %q{
          push f.l 0
          cursor
            push f.l 1
            alice on_cancel: (def \ break 'breaking...')
            push f.l 2
          push f.l 3 if f.ret == 'breaking...'
          push f.l 4
        },
        payload: { 'l' => [] },
        wait: 'end')

      @unit.cancel(r['exid'], '0_1_1')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 0, 1, 'dt_m36', 3, 4 ])
    end

    it 'does not bite its tail (task) and the "cause" is preserved' do # gh-26

      @unit.add_tasker(
        'bob',
        class SpucBobTasker < Flor::BasicTasker
          def on_task
#p :task!
            payload['l'] << 'ot'
            []
          end
          def on_detask
#p :detask!
            message.delete('cause')
            payload['l'] << 'odt'
            reply
          end
          self
        end)

      r = @unit.launch(
        %q{
          loop
            bob on_cancel: (def \ push f.l 'oc' | break _)
        },
        payload: { 'l' => [] },
        wait: 'end')

      @unit.cancel(r['exid'], '0_0')

      r = @unit.wait(r['exid'], 'terminated')

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ odt oc ])
      expect(r['cause'].collect { |m| m['m'] }).to eq([ 33, 32, 14 ])
    end
  end
end

