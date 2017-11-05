
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

      r = @executor.launch(%q{ + _ })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'adds two numbers' do

      r = @executor.launch(
        %q{
          +
            1
            2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 3 })
    end

    it 'adds three numbers' do

      r = @executor.launch(
        %q{
          +
            3
            2
            -1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 4 })
    end

    it 'adds two strings' do

      r = @executor.launch(
        %q{
          + "fa" "ble"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('fable')
    end

    it 'fails if adding a string to a number' do

      r = @executor.launch(
        %q{
          + 1 "nada"
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['kla']
        ).to eq('TypeError')
      expect(r['error']['msg']
        ).to match(/\AString can't be coerced into (Integer|Fixnum)\z/)
    end

    it 'turns numbers intro strings when adding to a strings' do

      r = @executor.launch(
        %q{
          + "" 1 true [ 1 2 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('1true[1, 2]')
    end
  end

  describe '-' do

    it 'substracts' do

      r = @executor.launch(
        %q{
          -
            1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'substracts' do

      r = @executor.launch(
        %q{
          -
            3
            2
            -1
            5
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -3 })
    end

    it 'returns 0 if empty' do

      r = @executor.launch(%q{ - _ })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'accepts 3 or more numbers' do

      r = @executor.launch(%q{ (- 3 4 5) })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end

  describe '*' do

    it 'returns 1 if empty' do

      r = @executor.launch(%q{ * _ })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'multiplies three numbers' do

      r = @executor.launch(
        %q{
          *
            3
            2
            -1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => -6 })
    end
  end

  describe '/' do

    it 'divides' do

      r = @executor.launch(
        %q{
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
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 0.5 ])
    end

    it 'returns 1 when empty' do

      r = @executor.launch(%q{ / _ })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it 'accepts 3 or more numbers' do

      r = @executor.launch(
        %q{
          set l []
          push l (/ 3 4 5)
          push l (/ 3.0 4 5)
          l
        })

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

