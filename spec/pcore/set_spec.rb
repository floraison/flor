
#
# specifying flor
#
# Tue Feb  2 16:33:43 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'set' do

    it 'has no effect on its own' do

      flor = %{
        set _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({})
      expect(r['vars'].has_key?('_')).to be(false)
    end

    it 'sequences its children' do

      flor = %{
        set f.a
          0
          1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => 1, 'ret' => nil })
    end

    it 'sets fields' do

      flor = %{
        set f.a
          0
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => nil })
    end

    it 'sets fields deep' do

      flor = %{
        set f.h.count
          7
        set f.i.1
          8
      }

      r = @executor.launch(
        flor,
        payload: { 'h' => {}, 'i' => [ 0, 1 ] })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})

      expect(
        r['payload']
      ).to eq({
        'h' => { 'count' => 7 }, 'i' => [ 0, 8 ], 'ret' => nil
      })
    end

    it 'fails when it cannot set a deep field' do

      flor = %{
        set f.h.i.j
          7
      }

      r = @executor.launch(flor, payload: { 'h' => {} })

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set field h.i.j")
      expect(r['payload']).to eq({ 'h' => {}, 'ret' => 7 })
    end

    it 'sets variables' do

      flor = %{
        set v.a
          0
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 0 })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'sets variables deep' do

      flor = %{
        set v.h.count
          8
      }

      r = @executor.launch(flor, vars: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'h' => { 'count' => 8 } })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'fails when it cannot set a deep variable' do

      flor = %{
        set v.h.i.j
          9
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set var v.h.i.j")
      expect(r['payload']).to eq({ 'ret' => 9 })
    end

    it 'leaves f.ret untouched' do

      flor = %{
        11
        set f.a 12
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(12)
      expect(r['payload']['ret']).to eq(11)
    end

    it 'leaves f.ret unless explicitely setting it' do

      flor = %{
        11
        set f.ret 12
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(12)
    end

    it 'accepts bracketed keys' do

      flor = %q{ # <-------------- using q to make the \"pullover\" work
        set f.a.0 'zero'
        set "f.a[1]" 'one'
        set f.h.name 'Haddock'
        set "f.h[age]" 45
        set "f.h['hair']" 'black'
        set 'f.h["state"]' 'drunk'
        set "f.h[\"pullover\"]" 'blue'
        set f.h["accessory"] 'pipe'
      }

      r = @executor.launch(flor, payload: { 'h' => {}, 'a' => [ 0, 1, 2 ] })

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']
      ).to eq({
        'h' => {
          'name' => 'Haddock', 'age' => 45, 'hair' => 'black',
          'state' => 'drunk', 'pullover' => 'blue', 'accessory' => 'pipe' },
        'a' => [
          'zero', 'one', 2 ],
        'ret' =>
          nil
      })
    end
  end

  describe 'set a' do

    it 'sets locally if there is no a in the lookup chain' do

      flor = %{
        sequence
          sequence vars: {}
            set a
              1
            push f.l
              a
          push f.l
            a
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      flor = %{
        sequence
          set a
            0
          set a
            1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      flor = %{
        sequence
          set a
            0
          sequence vars: {}
            set a
              1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set v.a' do

    it 'sets locally if there is no a in the lookup chain' do

      flor = %{
        sequence
          sequence vars: {}
            set v.a
              1
            push f.l
              a
          push f.l
            a
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      flor = %{
        sequence
          set v.a
            0
          set v.a
            1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      flor = %{
        sequence
          set v.a
            0
          sequence vars: {}
            set v.a
              1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set lv.a' do

    it 'always sets locally' do

      flor = %{
        sequence
          set lv.a
            0
          set b
            10
          set lv.a
            1
          set lv.b
            11
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 1, 'b' => 11 })
    end
  end

  describe 'set f.a' do

    it 'sets a field' do

      flor = %{
        sequence
          set f.a
            0
          set f.b 1
          set f.c (-2)
          set f.d { a: 0, b: 1 }
          set f.e
            { c: 2, d: 3 }
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']
      ).to eq({
        'a' => 0, 'b' => 1, 'c' => -2,
        'd' => { 'a' => 0, 'b' => 1 },
        'e' => { 'c' => 2, 'd' => 3 },
        'ret' => nil
      })
    end
  end

  describe 'setr' do

    it 'sets and returns the just set value' do

      flor = %{
        setr f.a
          0
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => 0 })
    end
  end
end

