
#
# specifying flor
#
# Fri Feb 26 17:33:04 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'push' do

    it 'pushes a value in a list' do

      rad = %{
        push f.l
          7
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
      expect(r['payload']['l']).to eq([ 7 ])
    end

    it 'pushes the result of its last child' do

      rad = %{
        push f.l
          1
          2
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
      expect(r['payload']['l']).to eq([ 2 ])
    end

    it 'pushes its second attribute if any' do

      rad = %{
        push f.l 7
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
      expect(r['payload']['l']).to eq([ 7 ])
    end

    it 'does not push anything if there is nothing to push' do

      rad = %{
        push f.l
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([])
    end
  end
end

