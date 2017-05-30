
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
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
        { 'a' => 1, 'b' => [], 'c' => [ 2, 3 ], 'd' => 4 } ],

      [ %q{ _pat_arr \ 7 }, 7, nil ],

      [ %q{ _pat_arr \ a; ___; c__2; d },
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
        { 'a' => 1, 'c' => [ 7, 8 ], 'd' => 9 } ]

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

      it 'accepts a nested _pat_guard'

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

