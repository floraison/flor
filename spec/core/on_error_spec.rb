
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

      flon = %{
        define dofail err; noop
        sequence on_error: dofail
          push f.l 0
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'fails if the handler does not exist'
    it 'triggers when a child has an error'
  end
end

