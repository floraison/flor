
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

    {

      'terminated' => [
        [ [ nil, [ 'terminated' ] ] ],
        nil,
        'fail' ],

      '0_0 task' => [
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'fail' ],

      '0_0 task; terminated' => [
        [ [ '0_0', [ 'task' ] ],
          [ nil, [ 'terminated' ] ] ],
        nil,
        'fail' ],

      '0_0 task|cancel; terminated' => [
        [ [ '0_0', [ 'task', 'cancel' ] ],
          [ nil, [ 'terminated' ] ] ],
        nil,
        'fail' ],

      '0_0 task,cancel; 0_1 task|cancel' => [
        [ [ '0_0', [ 'task', 'cancel' ] ],
          [ '0_1', [ 'task', 'cancel' ] ] ],
        nil,
        'fail' ],

      '0_0 task , cancel ; 0_1 task | cancel' => [
        [ [ '0_0', [ 'task', 'cancel' ] ],
          [ '0_1', [ 'task', 'cancel' ] ] ],
        nil,
        'fail' ],

      { wait: '0_0 task', timeout: 12 } => [
        [ [ '0_0', [ 'task' ] ] ],
        12,
        'fail' ],

      { wait: '0_0 task', on_timeout: 'shutup' } => [
        [ [ '0_0', [ 'task' ] ] ],
        nil,
        'shutup' ],

    }.each do |k, v|

      as = k.is_a?(String) ? { wait: k } : k

      it "expands #{as.inspect[1..-2]} correctly" do

        expect(@waiter.expand_args(as)).to eq(v)
      end
    end
  end
end

