
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
    end

    after :each do

      @unit0.shutdown
      @unit1.shutdown
    end

    it 'launches in 1 and processes in 0' do

      exid = @unit1.launch(
        %q{
          + 1 2 3
        })

      wait_until do
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

    it 'let the launcher wait for an execution termination' do

      exe = @unit1.launch(
        %q{
          + 1 2 3
        },
        wait: 'status:terminated')

      expect(@unit0.journal.count).to eq(10)
      expect(@unit1.journal.count).to eq(0)

      expect(@unit1.storage.executions.count).to eq(1)

      expect(exe.status).to eq('terminated')
      expect(exe.closing_messages.first['payload']).to eq('ret' => 6)
    end
  end
end

