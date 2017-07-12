
#
# specifying flor
#
# Sun May 21 10:40:12 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_arr' do

    it "doesn't match if the value is not an array" do

      r = @executor.launch(
        %q{ _pat_arr \ a; b; c },
        payload: { 'ret' => 0 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['_pat_binding']).to eq(nil)
    end

    it "doesn't match if the size differs (pattern is bigger)" do

      r = @executor.launch(
        %q{ _pat_arr \ a; b; c },
        payload: { 'ret' => [ 0 ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['_pat_binding']).to eq(nil)
    end

    it "doesn't match if the size differs (pattern is smaller)" do

      r = @executor.launch(
        %q{ _pat_arr \ a; b },
        payload: { 'ret' => [ 0, 1, 2 ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['_pat_binding']).to eq(nil)
    end

    [

      [ [ '_pat_arr', 0, 1 ], 6, nil ],
      [ %q{ _pat_arr \ 7 }, 7, nil ],

      [ [ '_pat_arr', 0, 1 ], [ 6 ], nil ],
      [ [ '_pat_arr', 0, 1 ], [], {} ],

      [ %q{ _pat_arr \ 7 }, [ 6 ], nil ],
      [ %q{ _pat_arr \ 7 }, [ 7 ], {} ],
      [ %q{ _pat_arr \ a }, [ 5 ], { 'a' => 5 } ],
      [ %q{ _pat_arr \ _; b }, [ 4, 5 ], { 'b' => 5 } ],

      [ %q{ _pat_arr \ a; b___; c },
        [ 4, 5, 6, 7 ],
        { 'a' => 4, 'b' => [ 5, 6 ], 'c' => 7 } ],

      [ %q{ _pat_arr \ a; b___; c; d },
        [ 4, 5, 6, 7, 8 ],
        { 'a' => 4, 'b' => [ 5, 6 ], 'c' => 7, 'd' => 8 } ],

      [ %q{ _pat_arr \ a; b___; c__2; d },
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
        { 'a' => 1, 'b' => [ 2, 3, 4, 5, 6 ], 'c' => [ 7, 8 ], 'd' => 9 } ],

      [ %q{ _pat_arr \ a; b__0; c__2; d },
        [ 1, 2, 3, 4 ],
        { 'a' => 1, 'b' => [], 'c' => [ 2, 3 ], 'd' => 4 } ],
      [ %q{ _pat_arr \ a; b__0; c__2; d },
        [ 1, 2, 3, 4, 5 ],
        nil ],

      [ %q{ _pat_arr \ 7 }, 7, nil ],

      [ %q{ _pat_arr \ a; ___; c__2; d },
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
        { 'a' => 1, 'c' => [ 7, 8 ], 'd' => 9 } ],

      [ %q{ _pat_arr \ 1; ___; c },
        [ 1, 2 ],
        { 'c' => 2 } ]

    ].each do |code, val, expected|

      c = code.is_a?(String) ? code.strip : code.inspect

      it(
        "#{expected == nil ? 'doesn\'t match' : 'matches'}" +
        " for `#{c}` vs `#{val.inspect}`"
      ) do

        r = @executor.launch(code, payload: { 'ret' => val })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')
        expect(r['payload']['_pat_binding']).to eq(expected)
      end
    end

    context 'nested patterns' do

      it 'accepts a nested _pat_arr' do

        r = @executor.launch(
          %q{
            # [ 1 b [ 3 d ] e___ ]
            _pat_arr
              1
              b
              _pat_arr
                3
                d
              e___
          },
          payload: { 'ret' => [ 1, 2, [ 3, 4 ], 5, 6 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'b' => 2, 'd' => 4, 'e' => [ 5, 6 ]
        })
      end

      it 'accepts a nested _pat_obj' do

        r = @executor.launch(
          %q{
            _pat_arr
              1
              b
              _pat_obj
                k0; c
                k1; d
              e
          },
          payload: { 'ret' => [ 1, 2, { 'k0' => 3, 'k1' => 4 }, 5 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5
        })
      end

      it 'accepts a nested _pat_or' do

        r = @executor.launch(
          %q{
            # [ 1, b, (or 3 33), d ]
            _pat_arr
              1
              b
              _pat_or
                3
                33
              d
          },
          payload: { 'ret' => [ 1, 2, 33, 4 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'b' => 2, 'd' => 4
        })
      end

  # Commenting that out.
  # This should be done using two _pat_arr
  # The _pat_or would become too complicated should it have to handle
  # that case
  #
#      it 'accepts a nested _pat_or of guards' do
#
#        r = @executor.launch(
#          %q{
#            _pat_arr
#              a
#              _pat_or
#                _pat_guard
#                  b___ (b.0 == 2)
#                _pat_guard
#                  c___
#              d
#          },
#          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ] })
#
#        expect(r['point']).to eq('terminated')
#
#        expect(
#          r['payload']['_pat_binding']
#        ).to eq({
#          'a' => 0
#        })
#      end

      it 'accepts a nested _pat_guard' do

        r = @executor.launch(
          %q{
            _pat_arr
              a
              _pat_guard
                b___
                (length b) > 3
              _pat_guard
                c__2
              d
          },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5, 6 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end

      it 'accepts a nested _pat_guard (2)' do

        r = @executor.launch(
          %q{
            _pat_arr
              a
              _pat_guard
                ___
                _pat_arr
                  bf
                  ___
                  bl
              _pat_guard
                c__2
              d
          },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5, 6 ] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => 0, 'bf' => 1, 'bl' => 3, 'c' => [ 4, 5 ], 'd' => 6
        })
      end

      it 'accepts a nested _pat_regex' do

        r = @executor.launch(
          [ '_pat_arr', [
            [ '_dqs', 'one', 1 ],
            [ '_pat_regex', "/^[tz][a-z]+$/", 1 ],
            [ '_pat_regex', "/^t[a-z]+$/", 1 ]
          ], 1 ],
          payload: { 'ret' => [ 'one', 'two', 'three' ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'matched' => 'three', 'match' => [ 'three' ]
        })
      end

      it 'accepts a nested _pat_regex nested in a _pat_guard' do

        r = @executor.launch(
          [ '_pat_arr', [
            [ '_dqs', 'one', 1 ],
            [ '_pat_guard', [
              [ '_dqs', 'two', 1 ],
              [ '_pat_regex', "/^[tz]([a-z]+)$/", 1 ]
            ], 1 ],
            [ '_pat_regex', "/^t[a-z]+$/", 1 ]
          ], 1 ],
          payload: { 'ret' => [ 'one', 'two', 'three' ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'two' => 'two',
          'two__matched' => 'two', 'two__match' => [ 'two', 'wo' ],
          'matched' => 'three', 'match' => [ 'three' ]
        })
      end

      it 'reads quantifiers from nested patterns' do

        r = @executor.launch(
          %q{
            _pat_arr
              a
              _pat_guard
                b___
              _pat_guard
                c__2
              d
          },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5, 6 ] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => 0, 'b' => [ 1, 2, 3 ], 'c' => [ 4, 5 ], 'd' => 6
        })
      end
    end
  end
end

