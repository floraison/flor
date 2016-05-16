
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

      flon = %{
        sequence
          stall _
      }

      Thread.new { @executor.launch(flon) }

      sleep 0.05

      ex = @executor.execution

      expect(ex['nodes'].keys).to eq(%w[ 0 0_0 ])
      expect(ex['errors']).to eq([])
      expect(ex['counters']).to eq({})
    end
  end
end

