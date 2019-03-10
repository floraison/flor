
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
        'fail'
      ])
    end

    it 'expands single points with nid' do

      expect(
        @waiter.expand_args(wait: '0_0 task')
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'fail'
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
        'fail'
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
        'fail'
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
        'fail'
      ])
    end

    it 'accepts a timeout:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', timeout: 12)
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        12,
        'fail'
      ])
    end

    it 'accepts an on_timeout:' do

      expect(
        @waiter.expand_args(wait: '0_0 task', on_timeout: 'shutup')
      ).to eq([
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'shutup'
      ])
    end
  end
end

