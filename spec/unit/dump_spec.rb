
#
# specifying flor
#
# Tue May  7 12:46:14 JST 2019  Shake Hands
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'udump'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe Flor do

    describe '.dump' do

      before :each do

        @exid0 = @unit.launch(%q{ stall _ })
        wait_until { @unit.executions.count == 1 }

        FileUtils.rm_f('tmp/dump.json')
      end

      after :each do

        FileUtils.rm_f('tmp/dump.json')
      end

      context '(db_uri)' do

        it 'dumps' do

          s = Flor.dump(@unit.storage.db.uri)
          h = JSON.parse(s)

          expect(h['executions'].collect { |e| e['exid'] }).to eq([ @exid0 ])
        end
      end

      context '(db)' do

        it 'dumps' do

          s = Flor.dump(@unit.storage.db)
          h = JSON.parse(s)

          expect(h['executions'].collect { |e| e['exid'] }).to eq([ @exid0 ])
        end
      end

      context '(unit)' do

        it 'dumps' do

          s = Flor.dump(@unit)
          h = JSON.parse(s)

          expect(h['executions'].collect { |e| e['exid'] }).to eq([ @exid0 ])
        end
      end
    end

    describe '.load' do

      before :each do

        @exid0 = @unit.launch(%q{ stall _ })
        wait_until { @unit.executions.count == 1 }

        File.open('tmp/dump.json', 'wb') { |f| @unit.dump(f) }

        @unit.storage.delete_tables
      end

      after :each do

        FileUtils.rm_f('tmp/dump.json')
      end

      context '(uri)' do

        it 'loads' do

          i = Flor.load(@unit.storage.db.uri, File.read('tmp/dump.json'))

          expect(@unit.storage.db[:flor_executions].map(:exid)).to eq([
            @exid0 ])

          expect(i).to eq({
            executions: 1, timers: 0, traps: 0, pointers: 0, total: 1 })
        end
      end

      context '(db)' do

        it 'loads' do

          i = Flor.load(@unit.storage.db, File.read('tmp/dump.json'))

          expect(@unit.storage.db[:flor_executions].map(:exid)).to eq([
            @exid0 ])

          expect(i).to eq({
            executions: 1, timers: 0, traps: 0, pointers: 0, total: 1 })
        end
      end
    end
  end
end

