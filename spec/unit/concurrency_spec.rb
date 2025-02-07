
#
# specifying flor
#
# Fri Feb  7 15:11:09 JST 2025
#

require 'spec_helper'


describe 'Flor unit' do

  describe 'sch_max_executor_count == 1' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json', sch_max_executors: 1)

      @unit.conf['unit'] = 'concurrency'
      @unit.hook('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start

      $_executor_count = 0
      $_peak_executor_count = 0
        #
      class << @unit
        attr_reader :max_executor_count
        attr_reader :executors
      end
      class << @unit.executors
        def <<(e)
          $_executor_count += 1
          r = super
          $_peak_executor_count =
            [ self.select(&:alive?).size, $_peak_executor_count ].max
          r
        end
      end
    end

    after :each do

      @unit.shutdown
    end

    it 'lets the unit execute 1 execution at a time' do

      expect(@unit.max_executor_count).to eq(1)
      expect(@unit.conf['sch_max_executors']).to eq(1)

      4.times do
        @unit.launch(
          %q{
            concurrence
              #stall 'a'
              #stall 'b'
              #stall 'c'
              sequence
                hole 'a'
              sequence
                hole 'b'
              sequence
                hole 'c'
              sequence
                hole 'd'
          })
      end

      @unit.wait('idle')
      #wait_until { @unit.journal.size >= 68 }

      expect($_peak_executor_count).to eq(1)
      expect($_executor_count).to eq(4)

      exids = @unit.journal.collect { |e| e['exid'].split('.').last }

      expect(exids[0]).not_to eq(exids[-1])
      expect(exids.uniq.count).to eq(4)

      swaps = 0
      exid0 = exids[0]
      exids.each { |i| swaps += 1 if i != exid0; exid0 = i }

      expect(swaps).to eq(3)
    end
  end

  describe 'sch_max_executor_count == 3' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf2.json')
        # where sch_max_executor_count is 3...

      @unit.conf['unit'] = 'concurrency'
      @unit.hook('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start

      $_executor_count = 0
      $_peak_executor_count = 0
        #
      class << @unit
        attr_reader :max_executor_count
        attr_reader :executors
      end
      class << @unit.executors
        def <<(e)
          $_executor_count += 1
          r = super
          $_peak_executor_count =
            [ self.select(&:alive?).size, $_peak_executor_count ].max
          r
        end
      end
    end

    after :each do

      @unit.shutdown
    end

    it 'lets the unit execute up to 3 executions at a time' do

      expect(@unit.max_executor_count).to eq(3)
      expect(@unit.conf['sch_max_executors']).to eq(3)

      4.times do
        @unit.launch(
          %q{
            concurrence
              sequence
                hole 'a'
              sequence
                hole 'b'
              sequence
                hole 'c'
              sequence
                hole 'd'
          })
      end

      @unit.wait('idle')
      #wait_until { @unit.journal.size >= 68 }

      expect($_peak_executor_count).to eq(3)
      expect($_executor_count).to eq(4)

      exids = @unit.journal.collect { |e| e['exid'].split('.').last }

      expect(exids[0]).not_to eq(exids[-1])
      expect(exids.uniq.count).to eq(4)

      swaps = 0
      exid0 = exids[0]
      exids.each { |i| swaps += 1 if i != exid0; exid0 = i }

      expect(swaps).to be > 14
        # usually between 20 and 30...
    end
  end
end

