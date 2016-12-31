
#
# specifying flor
#
# Wed Jul 20 17:04:44 JST 2016 Tcheliabinsk
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'the on_error: attribute' do

    it 'has no effect when no error' do

      flor = %{
        sequence on_error: (def err; _)
          push f.l 0
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'fails if the handler does not exist' do

      flor = %{
        sequence on_error: nada
          push f.l 0
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('don\'t know how to apply "nada"')
    end

    it 'triggers when a child has an error' do

      flor = %{
        sequence on_error: (def err; push f.l err.error.msg)
          push f.l 0
          push f.l x
          push f.l 1
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, "don't know how to apply \"x\"" ])
    end

    it 'accepts the name of a function' do

      flor = %{
        define mute err; 'muted.'
        sequence on_error: mute
          push f.l 0
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 'muted.' })
    end
  end
end

