
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

      r = @executor.launch(' set _ ')

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({})
      expect(r['vars'].has_key?('_')).to be(false)
    end

    it 'sequences its children' do

      r = @executor.launch(
        %q{
          set f.a
            0
            1
        })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => 1, 'ret' => nil })
    end

    it 'sets fields' do

      r = @executor.launch(
        %q{
          set f.a
            0
        })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => nil })
    end

    it 'sets fields deep' do

      r = @executor.launch(
        %q{
          set f.h.count
            7
          set f.i.1
            8
        },
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

      r = @executor.launch(
        %q{
          set f.h.i.j
            7
        },
        payload: { 'h' => {} })

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set field h.i.j")
      expect(r['payload']).to eq({ 'h' => {}, 'ret' => 7 })
    end

    it 'sets variables' do

      r = @executor.launch(
        %q{
          set v.a
            0
        })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 0 })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'sets variables deep' do

      r = @executor.launch(
        %q{
          set v.h.count
            8
        },
        vars: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'h' => { 'count' => 8 } })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'fails when it cannot set a deep variable' do

      r = @executor.launch(
        %q{
          set v.h.i.j
            9
        })

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set var v.h.i.j")
      expect(r['payload']).to eq({ 'ret' => 9 })
    end

    it 'leaves f.ret untouched' do

      r = @executor.launch(
        %q{
          11
          set f.a 12
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(12)
      expect(r['payload']['ret']).to eq(11)
    end

    it 'leaves f.ret unless explicitely setting it' do

      r = @executor.launch(
        %q{
          11
          set f.ret 12
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(12)
    end

    it 'copies the value of f.ret by default' do

      r = @executor.launch(
        %q{
          14
          set a
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 14 })
      expect(r['payload']['ret']).to eq(14)
    end

    it 'copies the current, inner, f.ret (achtung)' do

      r = @executor.launch(
        %q{
          13
          set a f.ret
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 'a' })
      expect(r['payload']['ret']).to eq(13)
    end

    it 'accepts bracketed keys' do

      r = @executor.launch(
        %q{ # <-------------- using q to make the \"pullover\" work
          set f.a.0 'zero'
          set "f.a[1]" 'one'
          set f.h.name 'Haddock'
          set "f.h[age]" 45
          set "f.h['hair']" 'black'
          set 'f.h["state"]' 'drunk'
          set "f.h[\"pullover\"]" 'blue'
          set f.h["accessory"] 'pipe'
        },
        payload: { 'h' => {}, 'a' => [ 0, 1, 2 ] })

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

    it 'accepts results of function calls' do

      r = @executor.launch(
        %q{ # <--- q
          define f0 \ 0
          define f1 x \ 1 + x
          set f.a (f0 _)
          set f.b (f1 1)
          set f.aa
            f0 _
          set f.bb
            f1 1
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['a']).to eq(0)
      expect(r['payload']['b']).to eq(2)
      expect(r['payload']['aa']).to eq(0)
      expect(r['payload']['bb']).to eq(2)
    end

    it 'accepts results of function definitions' do

      r = @executor.launch(
        %q{ # <--- q
          set f0
            def
              0
          set f.a0
            f0 _
          set f.b0 (f0 _)

          set f1
            def \ 1
          set f.a1 (f1 _)
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['a0']).to eq(0)
      expect(r['payload']['b0']).to eq(0)

      expect(r['payload']['a1']).to eq(1)
    end

    it 'accepts results of (inline) function definitions' do

      r = @executor.launch(
        %q{ # <--- q
          set f2 (def \ 2)
          set f.a2 (f2 _)
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['a2']).to eq(2)
    end

    it "doesn't mind a last tag" do

      r = @executor.launch(
        %q{ # <--- q
          set a 2 tag: 'here'
        })

      expect(r['point']).to eq('terminated')

      expect(r['vars']['a']).to eq(2)
      expect(r['payload']['a2']).to eq(nil)

      ent = @executor.journal.find { |m| m['point'] == 'entered' }
      lef = @executor.journal.find { |m| m['point'] == 'left' }

      expect(ent['tags']).to eq(%w[ here ])
      expect(lef['tags']).to eq(%w[ here ])
    end
  end

  describe 'set a' do

    it 'sets locally if there is no a in the lookup chain' do

      r = @executor.launch(
        %q{
          sequence
            sequence vars: {}
              set a
                1
              push f.l
                a
            push f.l
              a
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      r = @executor.launch(
        %q{
          sequence
            set a
              0
            set a
              1
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      r = @executor.launch(
        %q{
          sequence
            set a
              0
            sequence vars: {}
              set a
                1
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set v.a' do

    it 'sets locally if there is no a in the lookup chain' do

      r = @executor.launch(
        %q{
          sequence
            sequence vars: {}
              set v.a
                1
              push f.l
                a
            push f.l
              a
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      r = @executor.launch(
        %q{
          sequence
            set v.a
              0
            set v.a
              1
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      r = @executor.launch(
        %q{
          sequence
            set v.a
              0
            sequence vars: {}
              set v.a
                1
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set lv.a' do

    it 'always sets locally' do

      r = @executor.launch(
        %q{
          sequence
            set lv.a
              0
            set b
              10
            set lv.a
              1
            set lv.b
              11
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 1, 'b' => 11 })
    end
  end

  describe 'set f.a' do

    it 'sets a field' do

      r = @executor.launch(
        %q{
          sequence
            set f.a
              0
            set f.b 1
            set f.c (-2)
            set f.d { a: 0, b: 1 }
            set f.e
              { c: 2, d: 3 }
        })

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

      r = @executor.launch(
        %q{
          setr f.a
            0
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => 0 })
    end
  end

  context 'and splat' do

    it 'splats arrays' do

      r = @executor.launch(
        %q{
          set a b c
            [ 0 1 2 3 ]
          set d
            [ 4 5 6 ]
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq(nil)

      expect(r['vars']['a']).to eq(0)
      expect(r['vars']['c']).to eq(2)
      expect(r['vars']['d']).to eq([ 4, 5, 6 ])
    end

    it 'star-splats' do

      r = @executor.launch(
        %q{
          set a b___ c
            [ 0 1 2 3 ]
          set d e__2 f
            [ 4 5 6 7 8 ]
          set __2 g h
            [ 9 10 11 12 13 ]
          set i j___
            [ 14 15 16 17 18 19 ]
          set "k__$(c)" l
            [ 20 21 22 23 24 ]
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq(nil)

      expect(r['vars']['a']).to eq(0)
      expect(r['vars']['b']).to eq([ 1, 2 ])
      expect(r['vars']['c']).to eq(3)

      expect(r['vars']['d']).to eq(4)
      expect(r['vars']['e']).to eq([ 5, 6 ])
      expect(r['vars']['f']).to eq(7)

      expect(r['vars']['g']).to eq(11)
      expect(r['vars']['h']).to eq(12)

      expect(r['vars']['i']).to eq(14)
      expect(r['vars']['j']).to eq([ 15, 16, 17, 18, 19 ])

      expect(r['vars']['k']).to eq([ 20, 21, 22 ])
      expect(r['vars']['l']).to eq(23)
    end
  end
end

