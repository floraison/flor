
#
# specifying flor
#
# Tue May 17 06:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'stall' do

    it 'stalls' do

      r = @executor.launch(
        %q{
          sequence
            stall _
        })

      expect(r).to eq(nil)

      ex = @executor.execution

      expect(ex['nodes'].keys).to eq(%w[ 0 0_0 ])
      expect(ex['errors']).to eq([])
      expect(ex['counters']).to eq({ 'msgs' => 4 })
    end
  end
end

