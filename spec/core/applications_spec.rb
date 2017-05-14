
#
# specifying flor
#
# Sat Feb 20 20:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a value on its own' do

    it 'returns itself' do

      flor = %{
        3
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end

    it 'returns itself' do

      r = @executor.launch(
        %{
          3 tags: 'xyz'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
          }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        receive:0:
        execute:0_1:
        execute:0_1_0:
        execute:0_1_0_0:
        receive:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
        entered:0_1:xyz
        receive:0_1:
        receive:0:
        left:0_1:xyz
        receive::
        terminated::
      ].join("\n"))
    end
  end

  describe 'a procedure reference' do

    it 'returns the referenced procedure' do

      flor = %{
        sequence
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_proc', { 'proc' => 'sequence' }, -1 ]
      )
    end
  end

  describe 'a function reference' do

    it 'returns the referenced function' do

      flor = %{
        sequence
          define sum a, b
            # empty
          sum
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func',
          { 'nid' => '0_0', 'cnid' => '0', 'fun' => 0, 'ref' => 'sum' },
          3 ]
      )
    end
  end

  describe 'a function call' do

    it 'works' do

      flor = %{
        sequence
          define sum a, b
            +
              a
              b
          sum 1 2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end

    it 'runs each time with a different subnid' do

      flor = %{
        sequence
          define sub i
            push f.l
              #val $(nid)
              [ i, "$(nid)" ]
            + i 1
          sub 0
          sub 1
          sub 2
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        3
      )
      expect(
        r['payload']['l']
      ).to eq(
        [ [ 0, '0_0_2_1_1-1' ], [ 1, '0_0_2_1_1-2' ], [ 2, '0_0_2_1_1-3' ] ]
      )
    end

    it 'works with an anonymous function' do

      flor = %{
        sequence
          set sum
            def x y
              +
                x
                y
          sum 7 3
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(10)
    end

    it 'works with an anonymous function (f.ret)' do

      r = @executor.launch(
        %q{
          def x y \ (+ x y)
          f.ret 6 2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(8)
    end

    it 'works with an anonymous function (paren)' do

      r = @executor.launch(
        %q{
          (def x y \ (+ x y)) 7 2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(9)
    end
  end

  describe 'a closure' do

    it 'works (read)' do

      flor = %{
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

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(r['vars'].keys.sort).to eq(%w[ add3 make_adder ])
      #
      expect(r['vars']['make_adder']).to eq(
        [ '_func',
          { 'nid' => '0_0', 'cnid' => '0', 'fun' => 0, 'ref' => 'make_adder' },
          3 ]
      )
      expect(r['vars']['add3']).to eq(
        [ '_func',
          { 'nid' => '0_0_2-1', 'cnid' => '0_0-1', 'fun' => 1, 'ref' => 'add3' },
          4 ]
      )

      expect(r['payload']['ret']).to eq(10)

      nodes = @executor.execution['nodes']

      expect(nodes.keys).to eq(%w[ 0 0_0-1 ])
    end

    it 'works (write)' do

      # SICP p. 222

      flor = %{
        sequence
          define make-withdraw bal
            def amt
              setr bal
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

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 23, 10 ])

      #pp @executor.execution['nodes'].values
    end
  end
end

