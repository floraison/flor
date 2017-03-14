
#
# specifying flor
#
# Tue Mar 14 16:41:37 JST 2017
#

require 'spec_helper'


describe Flor::Runner do

  before :all do

    @runner = Flor::Runner.new(nil)
  end

  describe '#run' do

    context 'ruby' do

      it 'runs basic ruby classes' do

        r = @runner.run(
          nil,
          { 'require' => 'unit/hooks/for_runner',
            'class' => 'Romeo::Runnee',
            '_path' => 'spec/' },
          { 'point' => 'execute', 'm' => 1 })

        expect(r).to eq([ { 'point' => 'receive', 'mm' => 2 } ])
      end
    end

    context 'external' do

      it 'runs basic scripts'
    end
  end
end

