
#
# specifying flor
#
# Wed Feb 17 18:13:39 SGT 2016
#

require 'spec_helper'


describe 'Flor instructions' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sequence' do

    it 'works with integers' do

      rad = %{
        val v: 1
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'works with integers, directly' do

      rad = %{
        val 1
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'works with strings' do

      rad = %{
        val t: dqstring, v: "abc def"
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => "abc def" })
    end

    it 'works with strings, directly' do

      rad = %{
        val "abc def"
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => "abc def" })
    end

    context 'bare values' do

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
end


