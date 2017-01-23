
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
        @waiter.expand_args(wait: '0_0 task, terminated')
      ).to eq([
        [
          [ '0_0', [ 'task' ] ],
          [ nil, [ 'terminated' ] ]
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

    it 'accepts a repeat:' #do
#
#      expect(
#        @waiter.expand_args(wait: '0_0 task', repeat: 3)
#      ).to eq([
#        [ [ '0_0', [ 'task' ] ] ],
#        4,
#        3
#      ])
#    end
  end
end

