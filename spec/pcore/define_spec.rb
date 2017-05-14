
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

      r = @executor.launch(
        %q{
          define sum a, b
            +
              a
              b
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'sum' => r['payload']['ret'] })

      expect(r['payload']['ret'][0]).to eq('_func')
      expect(r['payload']['ret'][1]['nid']).to eq('0')
      expect(r['payload']['ret'][1]['cnid']).to eq('0')
      expect(r['payload']['ret'][1]['fun']).to eq(0)
      expect(r['payload']['ret'][1]['tree'][0]).to eq('define')
      expect(r['payload']['ret'][2]).to eq(2)
    end

    it 'binds at the last moment' do

      r = @executor.launch(
        %q{
          define "sum0" a, b \ (+ a b)
          set name 'su'
          define "$(name)m1" a, b \ (+ a b)
          define 'sum2' a, b \ (+ a b)
          set f.r0 (sum0 1, 2)
          set f.r1 (sum1 3, -1)
          set f.r2 (sum2 4, 5)
        })

      expect(r['point']).to eq('terminated')

      expect(
        r['vars'].keys
      ).to eq(%w[
        sum0 name sum1 sum2
      ])

      expect(r['payload']['ret'][0]).to eq('_func')
      expect(r['payload']['ret'][1]['nid']).to eq('0_3')
      expect(r['payload']['ret'][1]['cnid']).to eq('0')
      expect(r['payload']['ret'][1]['fun']).to eq(2)
      expect(r['payload']['ret'][1]['tree'][0]).to eq('define')
      expect(r['payload']['ret'][2]).to eq(5)

      expect(
        [ r['payload']['r0'], r['payload']['r1'], r['payload']['r2'] ]
      ).to eq([
        3, 2, 9
      ])
    end
  end

  describe 'def' do

    it 'returns a function' do

      r = @executor.launch(
        %q{
          def a, b
            +
              a
              b
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({})

      expect(r['payload']['ret'][0]).to eq('_func')
      expect(r['payload']['ret'][1]['nid']).to eq('0')
      expect(r['payload']['ret'][1]['cnid']).to eq('0')
      expect(r['payload']['ret'][1]['fun']).to eq(0)
      expect(r['payload']['ret'][1]['tree'][0]).to eq('def')
      expect(r['payload']['ret'][2]).to eq(2)
    end

    it 'defines functions with no arguments' do

      flor = %{
        def
          1 + 1
        f.ret _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end
  end

  describe 'fun' do

    it 'is an alias for "def"' do

      r = @executor.launch(
        %q{
          fun a, b
            +
              a
              b
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({})

      expect(r['payload']['ret'][0]).to eq('_func')
      expect(r['payload']['ret'][1]['nid']).to eq('0')
      expect(r['payload']['ret'][1]['cnid']).to eq('0')
      expect(r['payload']['ret'][1]['fun']).to eq(0)
      expect(r['payload']['ret'][1]['tree'][0]).to eq('fun')
      expect(r['payload']['ret'][2]).to eq(2)
    end
  end
end

