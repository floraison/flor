
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

    it 'returns 0 if empty' do

      flon = %{
        - _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'accepts 3 or more numbers' do

      flon = %{
        (- 3 4 5)
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end

  describe '*' do

    it 'returns 1 if empty' do

      flon = %{
        * _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
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

  describe '/' do

    it 'divides' do

      flon = %{
        set l []
        push l
          /
            1
            2
        push l
          /
            1.0
            2
        l
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0.5 ])
    end

    it 'returns 1 when empty' do

      flon = %{
        / _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it 'accepts 3 or more numbers' do

      flon = %{
        set l []
        push l (/ 3 4 5)
        push l (/ 3.0 4 5)
        l
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0.15 ])
    end
  end
end

