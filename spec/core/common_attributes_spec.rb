
#
# specifying flor
#
# Wed Dec 28 14:41:40 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  context 'common attributes' do

    describe 'vars:' do

      it 'does not set f.ret' do

        r = @executor.launch(
          %q{
            sequence vars: { a: 1 }
          })

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(nil)
      end

      it 'sets variables locally' do

        r = @executor.launch(
          %q{
            sequence vars: { a: 0 }
              push l [ a null ]
              sequence vars: { a: 1 b: 2 }
                push l [ a b ]
              push l [ a null ]
          },
          vars: { 'l' => [] })

        expect(r).to have_terminated_as_point

        expect(
          r['vars']['l']
        ).to eq(
          [ [ 0, nil ], [ 1, 2 ], [ 0, nil ] ]
        )
      end

      it 'sets variables locally (2)' do

        r = @executor.launch(
          %q{
            sequence
              set a 0
              push f.l "0_a:$(a)_b:$(b)"
              sequence vars: { a: 1, b: 1 }
                push f.l "1_a:$(a)_b:$(b)"
                set a 2
                push f.l "2_a:$(a)_b:$(b)"
              push f.l "3_a:$(a)_b:$(b)"
          },
          payload: { 'l' => [] })

        expect(r).to have_terminated_as_point

        expect(
          r['payload']['l']
        ).to eq(%w[
          0_a:0_b: 1_a:1_b:1 2_a:2_b:1 3_a:0_b:
        ])
      end

      context 'array' do

        it 'whitelists' do

          r = @executor.launch(
            %q{
              sequence vars: { a: 'A', b: 'B' }
                push f.l [ 0 a ]
                push f.l [ 0 b ]
                sequence vars: [ 'a' ]
                  push f.l [ 1 a ]
                  push f.l [ 1 b ]
            },
            payload: { 'l' => [] })

          expect(r['point']).to eq('failed')
          expect(r['error']['msg']).to eq("cannot find \"b\"")

          expect(
            r['payload']['l']
          ).to eq(
            [ [ 0, 'A' ], [ 0, 'B' ], [ 1, 'A' ] ]
          )
        end

        it 'whitelists with regexes' do

          r = @executor.launch(
            %q{
              sequence vars: { a_0: 'a', a_1: 'A', a_z: 'z', b_0: 'b' }
                push f.l "0__a_0:$(a_0)__a_1:$(a_1)__a_z:$(a_z)__b_0:$(b_0)"
                sequence vars: [ /^a_\d+/ ]
                  push f.l "0__a_0:$(a_0)__a_1:$(a_1)__a_z:$(a_z)__b_0:$(b_0)"
            },
            payload: { 'l' => [] })

          expect(r).to have_terminated_as_point

          expect(
            r['payload']['l']
          ).to eq(%w[
            0__a_0:a__a_1:A__a_z:z__b_0:b
            0__a_0:a__a_1:A__a_z:__b_0:
          ])
        end

        it 'blacklists' do

          r = @executor.launch(
            %q{
              sequence vars: { a: 'A', b: 'B', c: 'C' }
                push f.l "0|$(a)|$(b)|$(c)"
                sequence vars: [ '-', 'b', 'c' ]
                  ############## ^^^ '-', '^', or '!' as first element
                  push f.l "1|$(a)|$(b)|$(c)"
            },
            payload: { 'l' => [] })

          expect(r).to have_terminated_as_point

          expect(
            r['payload']['l']
          ).to eq(%w[
            0|A|B|C 1|A||
          ])
        end

        it 'blacklists with regexes' do

          r = @executor.launch(
            %q{
              sequence vars: { a: 'A', b: 'B', c: 'C' }
                push f.l "0|$(a)|$(b)|$(c)"
                sequence vars: [ '!', /^[bc]$/ ]
                  ############## ^^^ '-', '^', or '!' as first element
                  push f.l "1|$(a)|$(b)|$(c)"
            },
            payload: { 'l' => [] })

          expect(r).to have_terminated_as_point

          expect(
            r['payload']['l']
          ).to eq(%w[
            0|A|B|C 1|A||
          ])
        end

        # Since the vars: attribute only cares about '1st level' vars
        #
        it 'fails on deep keys' do

          r = @executor.launch(
            %q{
              sequence vars: [ 'a' 'b.c' 'd' ]
                _
            })

          expect(r['point']).to eq('failed')

          expect(
            r['error']['msg']
          ).to eq(
            'vars: is limited to 1st level, "b.c" doesn\'t comply'
          )
        end
      end

      context '"copy"' do

        it 'copies all the vars' do

          r = @executor.launch(
            %q{
              sequence vars: { c: 'C' }
                sequence vars: { a: 'A' }
                  push f.l [ 0 a ]
                  sequence vars: 'copy'
                    push f.l [ 1 a ]
                    set a 'B'
                    push f.l [ 2 a ]
                    push f.l [ 4 c ]
                  push f.l [ 3 a ]
            },
            payload: { 'l' => [] })

          expect(r).to have_terminated_as_point

          expect(
            r['payload']['l']
          ).to eq(
            [ [ 0, 'A' ], [ 1, 'A' ], [ 2, 'B' ], [ 4, 'C' ], [ 3, 'A' ] ]
          )
        end
      end

      context '"*"' do

        it 'copies all the vars' do

          r = @executor.launch(
            %q{
              sequence vars: { a: 'A' }
                push f.l [ 0 a ]
                sequence vars: '*'
                  push f.l [ 1 a ]
                  set a 'B'
                  push f.l [ 2 a ]
                push f.l [ 3 a ]
            },
            payload: { 'l' => [] })

          expect(r).to have_terminated_as_point

          expect(
            r['payload']['l']
          ).to eq(
            [ [ 0, 'A' ], [ 1, 'A' ], [ 2, 'B' ], [ 3, 'A' ] ]
          )
        end
      end

      context 'function reference' do

        it 'calls the function with a copy of the current vars as single arg'
      end

      context 'function call' do

        it 'uses the return (as expected)'
      end
    end

    describe 'ret:' do

      it 'overrides f.ret' do

        r = @executor.launch(
          %q{
            3 ret: 4
          })

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(4)
      end
    end

    describe 'off:/disable:/disabled:' do

      it 'turns off a node' do

        r = @executor.launch(
          %q{
            set a 0
            set a 1 off: false
            set a 2 off: true
            set a 3 disabled: true
          })

        expect(r).to have_terminated_as_point
        expect(r['vars']['a']).to eq(1)
      end
    end

    describe 'off/disabled' do

      it 'turns off a node' do

        r = @executor.launch(
          %q{
            set a 0
            set a 1 off
            set a 2 disabled
          })

        expect(r).to have_terminated_as_point
        expect(r['vars']['a']).to eq(0)
      end
    end
  end
end

