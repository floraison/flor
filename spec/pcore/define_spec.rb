
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

      expect(r).to have_terminated_as_point

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

      expect(r).to have_terminated_as_point

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

    it 'does not mind parentheses around the parameters' do

      r = @executor.launch(
        %q{
          define sum0 a, b \ (+ a b)
          define "sum1" (a, b, c) \ (+ a b)
          define sum2(a, b) \ (+ a b)
          set sum3
            def (a, b: 1) \ (+ a b)
          define sum4 a, b
            + a b
            42 # whatever, the answer is always 42...
        })

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['sum0'][1]['tree']
      ).to eq(
        [ 'define', [
          [ '_att', [ [ 'sum0', [], 2 ] ], 2 ],
          [ '_att', [ [ 'a', [], 2 ] ], 2 ],
          [ '_att', [ [ 'b', [], 2 ] ], 2 ],
          [ '+', [ [ 'a', [], 2 ], [ 'b', [], 2 ] ], 2 ]
        ], 2 ]
      )
      expect(
        r['vars']['sum1'][1]['tree']
      ).to eq(
        [ 'define', [
          [ '_att', [ [ '_sqs', 'sum1', 3 ] ], 3 ],
          [ '_att', [ [ 'a', [], 3 ] ], 3 ],
          [ '_att', [ [ 'b', [], 3 ] ], 3 ],
          [ '_att', [ [ 'c', [], 3 ] ], 3 ],
          [ '+', [ [ 'a', [], 3 ], [ 'b', [], 3 ] ], 3 ]
        ], 3 ]
      )
      expect(
        r['vars']['sum2'][1]['tree']
      ).to eq(
        [ 'define', [
          [ '_att', [ [ 'sum2', [], 4 ] ], 4 ],
          [ '_att', [ [ 'a', [], 4 ] ], 4 ],
          [ '_att', [ [ 'b', [], 4 ] ], 4 ],
          [ '+', [ [ 'a', [], 4 ], [ 'b', [], 4 ] ], 4 ]
        ], 4 ]
      )
      expect(
        r['vars']['sum3'][1]['tree']
      ).to eq(
        [ 'def', [
          [ '_att', [ [ 'a', [], 6 ] ], 6 ],
          [ '_att', [ [ 'b', [], 6 ], [ '_num', 1, 6 ] ], 6 ],
          [ '+', [ [ 'a', [], 6 ], [ 'b', [], 6 ] ], 6 ]
        ], 6 ]
      )
      expect(
        r['vars']['sum4'][1]['tree']
      ).to eq(
        [ 'define', [
          [ '_att', [ [ 'sum4', [], 7 ] ], 7 ],
          [ '_att', [ [ 'a', [], 7 ] ], 7 ],
          [ '_att', [ [ 'b', [], 7 ],], 7 ],
          [ '+', [ [ 'a', [], 8 ], [ 'b', [], 8 ] ], 8 ],
          [ '_num', 42, 9 ],
        ], 7 ]
      )
    end

    it 'accepts default parameter values' do

      r = @executor.launch(
        %q{
          define f a b:2 c:(3 + b)
            + a (2 * b) (3 * c)
          [ (f 2 1)
            (f b: 4 a: 1)
            (f a: 2 c: 1 b: -2) ]
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 16, 30, 1 ])
    end

#    it 'accepts fields in its signature' do ############################# FIXME
#
#      r = @executor.launch(
#        %q{
#          define f f.a f.b
#            + f.a f.b
#          f 1 2
#        })
#
#pp r['vars']
#      expect(r).to have_terminated_as_point
#      expect(r['payload']['a']).to eq(1)
#      expect(r['payload']['b']).to eq(2)
#      expect(r['payload']['ret']).to eq(3)
#    end
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

      expect(r).to have_terminated_as_point

      expect(r['vars']).to eq({})

      expect(r['payload']['ret'][0]).to eq('_func')
      expect(r['payload']['ret'][1]['nid']).to eq('0')
      expect(r['payload']['ret'][1]['cnid']).to eq('0')
      expect(r['payload']['ret'][1]['fun']).to eq(0)
      expect(r['payload']['ret'][1]['tree'][0]).to eq('def')
      expect(r['payload']['ret'][2]).to eq(2)
    end

    it 'defines functions with no arguments' do

      r = @executor.launch(
        %q{
          def
            1 + 1
          f.ret _
        })

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point

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

