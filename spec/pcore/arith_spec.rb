
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

      flor = %{
        + _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'adds two numbers' do

      flor = %{
        +
          1
          2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 3 })
    end

    it 'adds three numbers' do

      flor = %{
        +
          3
          2
          -1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 4 })
    end
  end

  describe '-' do

    it 'substracts' do

      flor = %{
        -
          1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'substracts' do

      flor = %{
        -
          3
          2
          -1
          5
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -3 })
    end

    it 'returns 0 if empty' do

      flor = %{
        - _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'accepts 3 or more numbers' do

      flor = %{
        (- 3 4 5)
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end

  describe '*' do

    it 'returns 1 if empty' do

      flor = %{
        * _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'multiplies three numbers' do

      flor = %{
        *
          3
          2
          -1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end

  describe '/' do

    it 'divides' do

      flor = %{
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

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0.5 ])
    end

    it 'returns 1 when empty' do

      flor = %{
        / _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it 'accepts 3 or more numbers' do

      flor = %{
        set l []
        push l (/ 3 4 5)
        push l (/ 3.0 4 5)
        l
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0.15 ])
    end
  end

  describe '%' do

    it 'returns the remainder' do

      r = @executor.launch(
        %q{
          [
            0 % 1
            10 % 5
            11 % 5
          ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0, 1 ])
    end

    it 'fails when there is 1 argument' do

      r = @executor.launch(%q{ % 1 })

      expect(r['point']).to eq('failed')

      expect(r['error']['msg'])
        .to eq('modulo % requires at least 2 arguments (line 1)')
    end

    it 'fails when there are 0 arguments' do

      r = @executor.launch(%q{ % _ })

      expect(r['point']).to eq('failed')

      expect(r['error']['msg'])
        .to eq('modulo % requires at least 2 arguments (line 1)')
    end
  end
end

