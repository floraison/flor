
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

  describe 'val' do

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

    it 'expands its argument' do

      rad = %{
        sequence
          val "$(nid)"
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => '0_0' })
    end
  end
end


