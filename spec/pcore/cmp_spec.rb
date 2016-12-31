
#
# specifying flor
#
# Wed Mar  2 20:44:53 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '=' do

    it 'compares strings' do

      flor = %{
        sequence
          push f.l
            =
              "alpha"
              "alpha"
          push f.l
            =
              "alpha"
              "bravo"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares integers' do

      flor = %{
        sequence
          push f.l
            =
              1
              1
              1
          push f.l
            =
              1
              -1
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares floats' do

      flor = %{
        sequence
          push f.l
            =
              1.0
              1.0
          push f.l
            =
              1.0
              1
          push f.l
            =
              1.0
              1.0000001
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, true, false ])
    end

    it 'compares booleans' do

      flor = %{
        sequence
          push f.l
            =
              true
              true
          push f.l
            =
              false
              false
          push f.l
            =
              true
              false
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, true, false ])
    end

    it 'compares nulls' do

      flor = %{
        sequence
          push f.l
            =
              null
              null
          push f.l
            =
              null
              false
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares arrays' do

      flor = %{
        sequence
          push f.l
            =
              [ 1, 2 ]
              [ 1, 2 ]
          push f.l
            =
              [ 1, 2 ]
              [ 1, 2 ]
              [ 'a' ]
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares objects' do

      flor = %{
        sequence
          push f.l
            =
              { a: 1, b: 2 }
              { a: 1, b: 2 }
          push f.l
            =
              { a: 1, b: 2 }
              { a: 1, b: 2, c: 3 }
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end
  end

  describe '<' do

    it 'compares integers' do

      flor = %{
        push f.l; < 2 3
        push f.l; < 3 2
        push f.l; > 2 3
        push f.l; > 3 2
        push f.l; > 3 2 1
        push f.l; > 3 2 4
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, false, true, true, false ])
    end

    it 'compares floats' do

      flor = %{
        push f.l; < 2.0 3.0
        push f.l; < 3 2.0
        push f.l; > 2.0 3.0
        push f.l; > 3 2.0
        push f.l; > 3 2.0 1.0
        push f.l; > 3 2.0 4.1
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, false, true, true, false ])
    end

    it 'compares strings' do

      flor = %{
        push f.l; < 'aa' 'bb'
        push f.l; < 'cc' 'bb'
        push f.l; > 'zz' 'cc' 'bb'
        push f.l; > 'bb' 'zz'
        push f.l; > 'zz' 'aa' 'bb'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, true, false, false ])
    end

    it 'fails when arguments are not comparable' do

      r = @executor.launch(%{ < 'a' 1 })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ < 'a' true })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ < true true })
      expect(r['point']).to eq('failed')
    end
  end
end

