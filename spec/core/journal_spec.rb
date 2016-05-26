
#
# specifying flor
#
# Thu May 26 21:15:18 JST 2016
#

require 'spec_helper'


describe 'Flor texecutor' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'journal' do

    it 'stays empty by default' do

      flon = %{
        sequence
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')

      expect(@executor.journal).to eq([])
    end

    it 'is kept if journal: true' do

      flon = %{
        sequence
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal.collect { |m| m['point'] }
      ).to eq(%w[
        execute receive terminated
      ])
    end
  end
end

