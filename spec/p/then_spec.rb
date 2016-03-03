
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
            push f.l 1
            push f.l 2
          push f.l 3
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
      expect(r['payload']['l']).to eq([ 1, 2, 3 ])
    end

    it 'does not run its children if $(f.ret) is not true' do

      rad = %{
        sequence
          1
          then
            push f.l 1
            push f.l 2
          push f.l 3
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
      expect(r['payload']['l']).to eq([ 3 ])
    end
  end

  describe 'else' do

    it 'runs its children if $(f.ret) is false' do

      rad = %{
        sequence
          false
          else
            push f.l 1
            push f.l 2
          push f.l 3
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
      expect(r['payload']['l']).to eq([ 1, 2, 3 ])
    end

    it 'does not run its children if $(f.ret) is not false' do

      rad = %{
        sequence
          1
          else
            push f.l 1
            push f.l 2
          push f.l 3
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
      expect(r['payload']['l']).to eq([ 3 ])
    end
  end
end

