
#
# specifying flor
#
# Sat Apr  2 11:18:12 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'cond' do

    it 'has no effect it it has no children' do

      rad = %{
        push f.l 0
        cond
        push f.l 1
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'triggers' do

      rad = %{
        set a 4
        cond
          a < 4
          "less than four"
          a < 7
          "less than seven"
          a < 10
          "less than ten"
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('less than seven')
    end
  end
end

