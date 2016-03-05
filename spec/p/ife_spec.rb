
#
# specifying flor
#
# Sat Mar  5 13:46:23 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'ife' do

    it 'has no effect it it has no children' do

      rad = %{
        sequence
          push f.l 0
          ife _
          push f.l 1
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'simply sets $(ret) if there are no then/else children' do

      rad = %{
        sequence
          ife
            true
          push f.l f.ret
          ife
            false
          push f.l f.ret
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'triggers the then child when $(ret) != false'
    it 'triggers the else child when $(ret) == false'
  end
end

#    it 'evaluates its first child as conditional' do
#    end

