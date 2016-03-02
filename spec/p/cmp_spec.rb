
#
# specifying flor
#
# Wed Mar  2 20:44:53 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '=' do

    it 'compares strings' do

      rad = %{
        sequence
          push f.l
            =
              val "alpha"
              val alpha
          push f.l
            =
              val "alpha"
              val "bravo"
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares integers' do

      rad = %{
        sequence
          push f.l
            =
              1
              1
          push f.l
            =
              1
              -1
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ true, false ])
    end
  end
end

