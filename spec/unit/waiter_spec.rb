
#
# specifying flor
#
# Tue Jan 24 07:42:13 JST 2017
#

require 'spec_helper'


describe Flor::Waiter do

  before :all do

    @waiter = Flor::Waiter.allocate
    class << @waiter
      public :expand_args
    end
  end

  describe '#expand_args' do

    it 'expands single points' do

      expect(
        @waiter.expand_args(wait: 'terminated')
      ).to eq([
        [ [ nil, [ 'terminated' ] ] ],
        nil,
        'fail',
        false
      ])
    end

    it 'expands single points with nid' do

      expect(
        @waiter.expand_args(wait: '0_0 task')
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'fail',
        false
      ])
    end

    it 'expands multiple points' do

      expect(
        @waiter.expand_args(wait: '0_0 task; terminated')
      ).to eq([
        [
          [ '0_0', [ 'task' ] ],
          [ nil, [ 'terminated' ] ]
        ],
        nil,
        'fail',
        false
      ])
    end

    it 'expands multiple points for a nid' do

      expect(
        @waiter.expand_args(wait: '0_0 task|cancel; terminated')
      ).to eq([
        [
          [ '0_0', [ 'task', 'cancel' ] ],
          [ nil, [ 'terminated' ] ]
        ],
        nil,
        'fail',
        false
      ])
    end

    it 'accepts comma or pipe to "or" points' do

      expect(
        @waiter.expand_args(wait: '0_0 task,cancel; 0_1 task|cancel')
      ).to eq([
        [
          [ '0_0', [ 'task', 'cancel' ] ],
          [ '0_1', [ 'task', 'cancel' ] ]
        ],
        nil,
        'fail',
        false
      ])
    end

    it 'accepts a timeout:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', timeout: 12)
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        12,
        'fail',
        false
      ])
    end

    it 'accepts an on_timeout:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', on_timeout: 'shutup')
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'shutup',
        false
      ])
    end

    it 'accepts a repeat:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', repeat: 3)
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'fail',
        3
      ])
    end
  end

  context 'as a launch option' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf['unit'] = 'waitertest'
      #@unit.hook('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start

      class << @unit
        attr_reader :wlist
      end
      class << @unit.wlist
        attr_reader :waiters
      end
    end

    after :each do

      @unit.shutdown
    end

    it 'lets wait until the scheduler gets idle' do

      r = @unit.launch(%{ sleep 10 }, wait: %w[ idle ] * 4)

      expect(r['point']).to eq('idle')
      expect(r['exid']).to eq(nil)

      expect(r.keys).to eq(%w[
        point idle_count consumed ])

      expect(r['idle_count']).to eq(4)
    end

    it 'lets wait until the executor run ends' do

      r = @unit.launch(%{ sleep 10 }, wait: 'end')

      expect(r['point']).to eq('end')
      expect(r['exid']).not_to eq(nil)

      expect(r.keys).to eq(%w[
        point exid start duration consumed counters
        nodes execution_size er pr ])
    end

    it 'lets wait until a tag is entered' do

      r = @unit.launch(
        %q{
          sequence tag: 'stage-a'
            push f.l 0
          sequence tag: 'stage-b'
            push f.l 1
            stall _
          sequence tag: 'stage-c'
            push f.l 2
        },
        payload: { l: [] },
        wait: 'entered')

      expect(r['point']).to eq('entered')
      expect(r['tags']).to eq(%w[ stage-a ])
      expect(r['nid']).to eq('0_0')
    end

    it 'lets wait until a given tag is entered' do

      r = @unit.launch(
        %q{
          sequence tag: 'stage-a'
            push f.l 0
          sequence tag: 'stage-b'
            push f.l 1
            stall _
          sequence tag: 'stage-c'
            push f.l 2
        },
        payload: { l: [] },
        wait: 'entered:stage-b')

      expect(r['point']).to eq('entered')
      expect(r['tags']).to eq(%w[ stage-b ])
      expect(r['nid']).to eq('0_1')
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'lets wait until a given tag is left' do

      r = @unit.launch(
        %q{
          sequence tag: 'stage-a'
            push f.l 0
          sequence tag: 'stage-b'
            push f.l 1
          sequence tag: 'stage-c'
            stall _
            push f.l 2
        },
        payload: { l: [] },
        wait: 'left:stage-b')

      expect(r['point']).to eq('left')
      expect(r['tags']).to eq(%w[ stage-b ])
      expect(r['nid']).to eq('0_1')
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

#    it 'understands timeout:' do
#
#      Thread.new do
#        @unit.launch(%{ sleep 10 }, wait: 'end', timeout: 7)
#      end
#      waiter = wait_until { @unit.wlist.waiters.first }
#
#      class << waiter; attr_reader :timeout; end
#
#      expect(waiter.timeout).to eq(7)
#    end
#
#    it 'understands on_timeout:' do
#
#      Thread.new do
#        @unit.launch(%{ sleep 10 }, wait: 'end', on_timeout: 'shutup')
#      end
#      waiter = wait_until { @unit.wlist.waiters.first }
#
#      class << waiter; attr_reader :on_timeout; end
#
#      expect(waiter.on_timeout).to eq('shutup')
#    end
  end

  context 'when called via unit#wait' do

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf['unit'] = 'unitwaittest'
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start
    end

    after :each do

      @unit.shutdown
    end

    it 'lets wait until the scheduler gets idle' do

      @unit.launch(%{ sleep 10 })

      sleep 1

      #r = @unit.wait(nil, 'idle')
      r = @unit.wait('idle')

      expect(r['point']).to eq('idle')
      expect(r['exid']).to eq(nil)

      expect(r.keys).to eq(%w[
        point idle_count consumed ])

      expect(r['idle_count']).to be > 0
    end
  end
end

