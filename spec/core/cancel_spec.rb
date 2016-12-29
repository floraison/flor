
#
# specifying flor
#
# Fri Dec 30 05:41:07 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # NOTA BENE: using "concurrence" even though it's deemed "unit" and not "core"

  describe 'cancel' do

     it 'cancels' do

       flon = %{
         concurrence
           sequence # 0_0
             stall _
           sequence
             _skip 7
             cancel '0_0'
       }

      r = @executor.launch(flon, archive: true)

      expect(r['point']).to eq('terminated')

      seq = @executor.archive['0_0']

pp seq
fail
#      expect(
#        @executor.journal.collect { |m| m['point'] }
#      ).to eq(%w[
#        execute receive terminated
#      ])
     end

     it "doesn't over-cancel"
     it 'over-cancels if flavoured'
  end
end

