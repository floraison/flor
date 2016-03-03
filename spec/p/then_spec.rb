
#
# specifying flor
#
# Fri Mar  4 06:26:53 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'then' do

    it 'runs its children if $(f.ret) is true' do

      rad = %{
        sequence
          true
          then
            push f.l
              1
            push f.l
              2
          push l
            3
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
      expect(r['payload']['l']).to eq([ 1, 2, 3 ])
    end

    it 'does not run its children if $(f.ret) is false'
  end

  describe 'else' do

    it 'runs its children if $(f.ret) is false'
    it 'does not run its children if $(f.ret) is true'
  end
end

