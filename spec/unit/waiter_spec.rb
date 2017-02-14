
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
        4,
        false
      ])
    end

    it 'expands single points with nid' do

      expect(
        @waiter.expand_args(wait: '0_0 task')
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        4,
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
        4,
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
        4,
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
        4,
        false
      ])
    end

    it 'accepts a timeout:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', timeout: 12)
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        12,
        false
      ])
    end

    it 'accepts a repeat:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', repeat: 3)
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        4,
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
        point exid start duration consumed counters nodes size er pr ])
    end
  end
end

