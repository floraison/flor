
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

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'ret' => nil })
      expect(r['vars'].has_key?('_')).to be(false)
    end

    it 'sequences its children' do

      r = @executor.launch(
        %q{
          set f.a
            0
            1
        })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => 1, 'ret' => nil })
    end

    it 'sets fields' do

      r = @executor.launch(
        %q{
          set f.a
            0
        })

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point
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
      expect(r['error']['kla']).to eq("IndexError")
      expect(r['error']['msg']).to eq("couldn't set field h.i.j")
      expect(r['payload']).to eq({ 'h' => {}, 'ret' => 7 })
    end

    it 'sets variables' do

      r = @executor.launch(
        %q{
          set v.a
            0
        })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 0 })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'sets variables' do

      r = @executor.launch(
        %q{
          1
          set a f.ret tag: 'nada'
        })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 1 })
      expect(r['payload']).to eq({ 'ret' => 1 })
    end

    it 'sets variables deep' do

      r = @executor.launch(
        %q{
          set v.h.count
            8
        },
        vars: { 'h' => {} })

      expect(r).to have_terminated_as_point
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
      expect(r['error']['kla']).to eq("IndexError")
      expect(r['error']['msg']).to eq("couldn't set var v.h.i.j")
      expect(r['payload']).to eq({ 'ret' => 9 })
    end

    it 'leaves f.ret untouched' do

      r = @executor.launch(
        %q{
          11
          set f.a 12
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['a']).to eq(12)
      expect(r['payload']['ret']).to eq(11)
    end

    it 'leaves f.ret unless explicitely setting it' do

      r = @executor.launch(
        %q{
          11
          set f.ret 12
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(12)
    end

    it 'copies the value of f.ret by default' do

      r = @executor.launch(
        %q{
          14
          set a
        })

      expect(r).to have_terminated_as_point
      expect(r['vars']).to eq({ 'a' => 14 })
      expect(r['payload']['ret']).to eq(14)
    end

    it 'accepts string keys' do

      r = @executor.launch(
        %q{
          set "f.h.name" 'TagUndNacht'
        },
        payload: { 'h' => {} })

      expect(r).to have_terminated_as_point

      expect(
        r['payload']
      ).to eq({
        'h' => { 'name' => 'TagUndNacht' },
        'ret' => nil
      })
    end

    it 'accepts bracketed keys' do

      r = @executor.launch(
        %q{
          set f.h["accessory"] 'pipe'
        },
        payload: { 'h' => {} })

      expect(r).to have_terminated_as_point

      expect(
        r['payload']
      ).to eq({
        'h' => { 'accessory' => 'pipe' },
        'ret' => nil
      })
    end

    it 'accepts string and bracketed keys' do

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

      expect(r).to have_terminated_as_point

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

      expect(r).to have_terminated_as_point

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

      expect(r).to have_terminated_as_point

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

      expect(r).to have_terminated_as_point

      expect(r['payload']['a2']).to eq(2)
    end

    it "doesn't mind a last tag" do

      r = @executor.launch(
        %q{ # <--- q
          set a 2 tag: 'here'
        })

      expect(r).to have_terminated_as_point

      expect(r['vars']['a']).to eq(2)
      expect(r['payload']['a2']).to eq(nil)

      ent = @executor.journal.find { |m| m['point'] == 'entered' }
      lef = @executor.journal.find { |m| m['point'] == 'left' }

      expect(ent['tags']).to eq(%w[ here ])
      expect(lef['tags']).to eq(%w[ here ])
    end

    it 'is ok with deep references' do

      r = @executor.launch(
        %q{
          set h0 { a: "a" }
          set h1 { a: "a", b: "b" }
          set h0[h1.a] h1.b
          h0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq({ 'a' => 'b' })
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
        expect(r['error']['msg']).to eq("cannot find \"a\"")
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

        expect(r).to have_terminated_as_point
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

        expect(r).to have_terminated_as_point
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
        expect(r['error']['msg']).to eq("cannot find \"a\"")
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

        expect(r).to have_terminated_as_point
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

        expect(r).to have_terminated_as_point
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

        expect(r).to have_terminated_as_point
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
              set f 'f'; set "f.$(f)" true
          })

        expect(r).to have_terminated_as_point

        expect(
          r['payload']
        ).to eq({
          'a' => 0, 'b' => 1, 'c' => -2,
          'd' => { 'a' => 0, 'b' => 1 },
          'e' => { 'c' => 2, 'd' => 3 },
          'f' => true,
          'ret' => nil
        })
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

        expect(r).to have_terminated_as_point

        expect(r['payload']['ret']).to eq(nil)

        expect(r['vars']['a']).to eq(0)
        expect(r['vars']['c']).to eq(2)
        expect(r['vars']['d']).to eq([ 4, 5, 6 ])
      end

      {

        'a b___ c' => { 'a' => 0, 'b' => [ 1, 2, 3, 4 ], 'c' => 5 },
        'a b__2 c' => { 'a' => 0, 'b' => [ 1, 2 ], 'c' => 3 },
        '__2 b c' => { 'b' => 2, 'c' => 3 },
        'a b___' => { 'a' => 0, 'b' => [ 1, 2, 3, 4, 5 ] },
        '"a__$(x)" b' => { 'a' => [ 0, 1, 2 ], 'b' => 3 },
        'a b__0 c___' => { 'a' => 0, 'b' => [], 'c' => [ 1, 2, 3, 4, 5 ] },
        'f.a f.b__2 f.c' => { 'f.a' => 0, 'f.b' => [ 1, 2 ], 'f.c' => 3 },

      }.each do |vars, expected|

        it "splats along #{vars.inspect}" do

          r = @executor.launch(
            %{
              set #{vars}
                [ 0 1 2 3 4 5 ]
            },
            vars: { 'x' => 3 })

          expect(r).to have_terminated_as_point

          expect(r['payload']['ret']).to eq(nil)

          h = expected
            .inject({}) { |hh, (k, _)|
              hh[k] =
                if k.match(/\Af\.(.+)\z/)
                  r['payload'][$1]
                else
                  r['vars'][k]
                end
              hh }

          expect(h).to eq(expected)
        end
      end
    end
  end

  describe 'setr' do

    it 'sets and returns the just set value' do

      r = @executor.launch(
        %q{
          setr f.a
            0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => 0 })
    end
  end
end

