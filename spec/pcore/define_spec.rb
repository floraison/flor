
#
# specifying flor
#
# Sat Feb 20 20:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'define' do

    it 'binds and returns a function' do

      flon = %{
        define sum a, b
          +
            a
            b
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'sum' => r['payload']['ret'] })

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0', 'cnid' => '0', 'fun' => 0 }, 2 ]
      )
    end

    it 'binds at the last moment' do

      flon = %{
        define "sum0" a, b; (+ a b)
        set name 'su'
        define "$(name)m1" a, b; (+ a b)
        define 'sum2' a, b; (+ a b)
        set f.r0 (sum0 1, 2)
        set f.r1 (sum1 3, -1)
        set f.r2 (sum2 4, 5)
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')

      expect(
        r['vars'].keys
      ).to eq(%w[
        sum0 name sum1 sum2
      ])

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0_3', 'cnid' => '0', 'fun' => 2 }, 5 ]
      )
      expect(
        [ r['payload']['r0'], r['payload']['r1'], r['payload']['r2'] ]
      ).to eq([
        3, 2, 9
      ])
    end
  end

  describe 'def' do

    it 'returns a function' do

      flon = %{
        def a, b
          +
            a
            b
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({})

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0', 'cnid' => '0', 'fun' => 0 }, 2 ]
      )
    end
  end

  describe 'fun' do

    it 'is an alias for "def"' do

      flon = %{
        fun a, b
          +
            a
            b
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({})

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0', 'cnid' => '0', 'fun' => 0 }, 2 ]
      )
    end
  end
end

