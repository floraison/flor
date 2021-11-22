
#
# specifying flor
#
# Mon Feb 13 06:21:52 JST 2017
#

require 'spec_helper'


describe Flor::Storage do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'stest'
    @unit.storage.delete_tables
    @unit.storage.migrate
    #@unit.start # no

    @db = @unit.storage.db
  end

  describe '#load_messages' do

    it 'loads only msgs for execution where the messages are all created' do

      d = 'domain0'

      @db[:flor_messages].insert(
        point: 'execute', exid: 'cc', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'bb', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'aa', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'cancel', exid: 'bb', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'aa', status: 'reserved-other', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      #@db[:flor_messages].insert(
      #  point: 'launch', exid: 'dd', status: 'archived', domain: d,
      #  ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'launch', exid: 'ee', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
        #
      @db[:flor_messages].where(exid: 'cc').update(mtime: Flor.tstamp)

      ms = @unit.storage.load_messages(1)

      expect(ms.keys).to eq(%w[ bb cc ])
      expect(ms['bb'].map { |m| m[:status] }.uniq).to eq(%w[ created ])
      expect(ms['cc'].map { |m| m[:status] }.uniq).to eq(%w[ created ])
      expect(ms['bb'].map { |m| m[:point] }).to eq(%w[ execute cancel ])
      expect(ms['cc'].map { |m| m[:point] }).to eq(%w[ execute ])
    end

    it 'does not consider "consumed" messages' do

      d = 'domain1'

      @db[:flor_messages].insert(
        point: 'execute', exid: 'cc', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'bb', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'cancel', exid: 'cc', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'bb', status: 'reserved-other', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)

      ms = @unit.storage.load_messages(1)

      expect(ms.keys).to eq(%w[ cc ])
      expect(ms['cc'].map { |m| m[:status] }.uniq).to eq(%w[ created ])
      expect(ms['cc'].map { |m| m[:point] }).to eq(%w[ cancel ])
    end

    it 'does not consider many "consumed" messages' do

      d = 'domain1'

      @db[:flor_messages].insert(
        point: 'execute', exid: 'a0', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a1', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a2', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a3', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a4', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a5', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a6', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'a7', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'cc', status: 'consumed', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'bb', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'cancel', exid: 'cc', status: 'created', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)
      @db[:flor_messages].insert(
        point: 'execute', exid: 'bb', status: 'reserved-other', domain: d,
        ctime: Flor.tstamp, mtime: Flor.tstamp)

      ms = @unit.storage.load_messages(1)

      expect(ms.keys).to eq(%w[ cc ])
      expect(ms['cc'].map { |m| m[:status] }.uniq).to eq(%w[ created ])
      expect(ms['cc'].map { |m| m[:point] }).to eq(%w[ cancel ])
    end
  end

  describe '#on(type, callback)' do

    it 'registers a callback' do

      @unit.storage.on(:pointers) { puts 'a' }
      @unit.storage.on(:pointers, :update) { puts 'b' }
      @unit.storage.on(:pointers, :any) { puts 'c' }

      expect(@unit.storage.callbacks.keys).to eq([ :pointers ])
      expect(@unit.storage.callbacks[:pointers].size).to eq(3)
      expect(@unit.storage.callbacks[:pointers][0][0, 1]).to eq([ [] ])
      expect(@unit.storage.callbacks[:pointers][1][0, 1]).to eq([ [ :update ] ])
      expect(@unit.storage.callbacks[:pointers][2][0, 1]).to eq([ [] ])
    end
  end
end

describe Flor::Storage do

  context 'when not archiving' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf[:unit] = 'u_storage'
      #@unit.hooker.add('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start
    end

    after :each do

      @unit.shutdown
    end

    it 'cleans messages' do

      expect(@unit.storage.db[:flor_messages].count).to eq(0)

      r = @unit.launch(
        %q{
          sequence
            sequence _
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.storage.db[:flor_messages].count == 0 }
        # which is some kind of expectation
    end
  end

  context 'when archiving' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf[:unit] = 'u_storage'
      #@unit.hooker.add('journal', Flor::Journal)
      @unit.storage.archive = true
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start
    end

    after :each do

      @unit.shutdown
    end

    it 'archives important messages' do

      expect(@unit.storage.db[:flor_messages].count).to eq(0)

      r = @unit.launch(
        %q{
          sequence
            sequence _
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.storage.db[:flor_messages].count == 2 }

      expect(
        @unit.storage.db[:flor_messages].select(:point, :status).to_a
      ).to eq([
        { point: 'execute', status: 'consumed' },
        { point: 'terminated', status: 'consumed' },
      ])
    end
  end

  context 'primary keys' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf[:unit] = 'u_storage_pks'
      #@unit.hooker.add('journal', Flor::Journal)
      @unit.storage.archive = true
      @unit.storage.delete_tables
      @unit.storage.migrate
      #@unit.start
    end

    they 'auto increment' do

      r0 = @unit.launch('alpha _')
      r1 = @unit.launch('bravo _')

#      m0, m1 = @unit.storage.db[:flor_messages].sort_by { |m| m[:exid] }
#p [ m0[:id], m1[:id], '/', m0[:exid], m1[:exid] ]
      m0, m1 = @unit.storage.db[:flor_messages].sort_by { |m| m[:id] }
#p [ m0[:id], m1[:id], '/', m0[:exid], m1[:exid] ]

      expect(m1[:id]).not_to eq(m0[:id])
      expect(m1[:id]).to eq(m0[:id] + 1)
    end
  end

  context 'callbacks' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf[:unit] = 'u_storage_cbacks'
      #@unit.hooker.add('journal', Flor::Journal)
      #@unit.storage.archive = true
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start
    end

    they 'are called for :pointers' do

      seen = []
        #
      @unit.storage.on(:pointers, :update) do |table, action|
        seen << [ table, action ]
      end
      @unit.storage.on(:pointers, :update) do |table|
        seen << [ table ]
      end
      @unit.storage.on(:executions, :any) do |table, action, id|
        seen << [ table, action, id ]
      end

      r = @unit.launch('hole task: "nada"', wait: '0 task')

      id = wait_until { @unit.storage.db[:flor_executions].get(:id) }

      expect(seen).to eq([
        [ :executions, :insert, id ],
        [ :pointers, :update ],
        [ :pointers ],
      ])
    end
  end
end

