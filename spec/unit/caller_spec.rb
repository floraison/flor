
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

      it 'calls basic scripts' do

        r = @caller.call(
          nil,
          { 'cmd' => 'python spec/unit/hooks/for_caller.py',
            '_path' => 'spec/' },
          { 'point' => 'execute',
            'payload' => { 'items' => 2 } })

        expect(
          r
        ).to eq([
          { 'point' => 'receive',
            'payload' => { 'items' => 2, 'price' => 'CHF 5.00' } }
        ])
      end
    end
  end
end

