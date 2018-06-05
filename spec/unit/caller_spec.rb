
#
# specifying flor
#
# Tue Mar 14 16:41:37 JST 2017
#

require 'spec_helper'


describe Flor::Caller do

  before :all do

    @caller = Flor::Caller.new(nil)
  end

  describe '#call' do

    context 'ruby' do

      it 'calls basic ruby classes' do

        r = @caller.call(
          nil,
          { 'require' => 'unit/hooks/for_caller',
            'class' => 'Romeo::Callee',
            '_path' => 'spec/' },
          { 'point' => 'execute', 'm' => 1 })

        expect(r).to eq([ { 'point' => 'receive', 'mm' => 2 } ])
      end
    end

    context 'external' do

      it 'calls basic scripts'
    end
  end
end

