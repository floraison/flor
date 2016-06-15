
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

      flon = %{
        sequence
          push f.l 0
          ife _
          push f.l 1
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'simply sets $(ret) if there are no then/else children' do

      flon = %{
        sequence
          ife
            true
          push f.l
          ife
            false
          push f.l
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'triggers the then child when $(ret) true' do

      flon = %{
        sequence
          ife
            true
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) false' do

      flon = %{
        sequence
          ife
            false
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end

    it 'does not mind atts on the ife' do

      flon = %{
        ife false tag: 'nada'
          'then'
          'else'
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('else')
    end
  end

  describe 'unlesse' do

    it 'triggers the then child when $(ret) false' do

      flon = %{
        sequence
          unlesse
            false
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) true' do

      flon = %{
        sequence
          unlesse
            true
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end
  end
end

