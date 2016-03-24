
#
# specifying flor
#
# Sat Feb 20 20:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a procedure reference' do

    it 'returns the referenced procedure' do

      rad = %{
        sequence
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_proc', 'sequence', -1 ]
      )
    end
  end

  describe 'a function reference' do

    it 'returns the referenced function' do

      rad = %{
        sequence
          define sum a, b
            # empty
          sum
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0_0', 'cnid' => '0' }, 3 ]
      )
    end
  end

  describe 'a function call' do

    it 'works' do

      rad = %{
        sequence
          define sum a, b
            +
              a
              b
          sum 1 2
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end

    it 'runs each time with a different subnid' do

      rad = %{
        sequence
          define sub i
            push f.l
              #val $(nid)
              [ i, "$(nid)" ]
          sub 0
          sub 1
          sub 2
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0_0_0-3')
      expect(r['payload']['l']).to eq(%w[ 0_0_0_0-1 0_0_0_0-2 0_0_0_0-3 ])
    end

    it 'works with an anonymous function' do

      rad = %{
        sequence
          set sum
            def x y
              +
                x
                y
          sum 7 3
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(10)
    end
  end

  describe 'a closure' do

    it 'works (read)' do

      rad = %{
        sequence
          define make_adder x
            def y
              +
                x
                y
          set add3
            make_adder 3
          add3 7
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(10)

      nodes = @executor.execution['nodes']

      expect(nodes.keys).to eq(%w[ 0 0_0-1 ])
    end

    it 'works (write)' do

      # SICP p. 222

      rad = %{
        sequence
          define make-withdraw bal
            def amt
              set bal
                -
                  bal
                  amt
          set w0
            make-withdraw 100
          push f.l
            w0 77
          push f.l
            w0 13
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 23, 10 ])

      #pp @executor.execution['nodes'].values
    end
  end
end

