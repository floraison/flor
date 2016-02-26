
#
# specifying flor
#
# Fri Feb 26 11:48:09 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'bare value' do

    it 'works with symbols' do

      rad = %{
        nada
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"nada\"")
    end

    it 'does not work with strings' do

      r = @executor.launch(%{ "abc def" })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"abc def\"")
    end

    it 'works with arrays' do

      r = @executor.launch(%{ [ 1, 2, "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        [ 1, 2, [ val, { t: dqstring, v: trois }, 1, [] ] ]
      }.strip)
    end

    it 'works with objects' do

      r = @executor.launch(%{ { a: 'A' } })

      expect(r['point']).to eq('terminated')
      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        { a: [ val, { t: sqstring, v: A }, 1, [] ] }
      }.strip)
    end

    it 'works with numbers' do

      r = @executor.launch(%{ 11 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 11 })
    end
  end
end

