
#
# specifying flor
#
# Sat Jan  9 17:33:25 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '+' do

    it 'returns 0 if empty' do

      flon = %{
        + _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'adds two numbers' do

      flon = %{
        +
          1
          2
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 3 })
    end

    it 'adds three numbers' do

      flon = %{
        +
          3
          2
          -1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 4 })
    end
  end

  describe '-' do

    it 'substracts' do

      flon = %{
        -
          1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'substracts' do

      flon = %{
        -
          3
          2
          -1
          5
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -3 })
    end
  end

  describe '*' do

    it 'returns 0 if empty' do

      flon = %{
        * _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'multiplies three numbers' do

      flon = %{
        *
          3
          2
          -1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end
end

