
#
# specifying flor
#
# Tue May 23 06:15:46 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_obj' do

    it "doesn't match if the value is not an object" do

      r = @executor.launch(
        %q{ _pat_obj \ a; 1 },
        payload: { 'ret' => 0 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['_pat_binding']).to eq(nil)
    end

    [

      [ %q{ _pat_obj \ a; 1 }, 1, nil ], # "doesn't match if value not object"
      [ %q{ _pat_obj \ a; 1 }, { 'a' => 2 }, nil ],
      [ %q{ _pat_obj \ a; 1 }, { 'a' => 1 }, {} ],
      [ %q{ _pat_obj \ a; _ }, { 'a' => 1 }, {} ],
      [ %q{ _pat_obj \ a; b }, { 'a' => 2 }, { 'b' => 2 } ],
      [ %q{ _pat_obj \ a; b__1 }, { 'a' => 3 }, { 'b' => 3 } ],
      [ %q{ _pat_obj \ a; ___ }, { 'a' => 4 }, {} ],

    ].each do |code, val, expected|

      it(
        "#{expected == nil ? 'doesn\'t match' : 'matches'}" +
        " for `#{code.strip.to_s}` vs `#{val.inspect}`"
      ) do

        r = @executor.launch(code, payload: { 'ret' => val })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')
        expect(r['payload']['_pat_binding']).to eq(expected)
      end
    end

    context 'keys' do

      it 'turns keys into strings' do

        r = @executor.launch(
          %q{
            _pat_obj
              7
              _
          },
          payload: { 'ret' => { '7' => 1 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({})
      end

      it 'evaluates keys' do

        r = @executor.launch(
          %q{
            set a "colour"
            _pat_obj
              a
              b
          },
          payload: { 'ret' => { 'colour' => 'blue' } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'b' => 'blue' })
      end

      it 'quotes all keys when `quote: \'keys\'`' do

        r = @executor.launch(
          %q{
            set a "colour"
            _pat_obj quote: 'keys'
              a; v0
              (a _); v1
              7; v2
          },
          payload: { 'ret' => {
            'a' => 0, 'colour' => 'blue', '7' => 'seven' } })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'v0' => 0, 'v1' => 'blue', 'v2' => 'seven'
        })
      end
    end

    context 'only' do

      it 'matches `only`' do

        r = @executor.launch(
          %q{
            _pat_obj only
              a; _
              b; _
          },
          payload: { 'ret' => { 'a' => 0, 'b' => 1 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({})
      end

      it 'does not match if there are extra keys `only`' do

        r = @executor.launch(
          %q{
            _pat_obj only
              a; _
              b; _
          },
          payload: { 'ret' => { 'a' => 0, 'b' => 1, 'c' => 2 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end

      it 'matches `only: true`' do

        r = @executor.launch(
          %q{
            _pat_obj only: true
              a; _
              b; _
          },
          payload: { 'ret' => { 'a' => 0, 'b' => 1 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({})
      end

      it 'does not match if there are extra keys `only: true`' do

        r = @executor.launch(
          %q{
            _pat_obj only: true
              a; _
              b; _
          },
          payload: { 'ret' => { 'a' => 0, 'b' => 1, 'c' => 2 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context 'nested patterns' do

      it 'accepts a nested _pat_arr' do

        r = @executor.launch(
          %q{
            _pat_obj
              a; a
              b; _pat_arr
                1
                b
              c; c
          },
          payload: { 'ret' => { 'a' => 0, 'b' => [ 1, 2 ], 'c' => 3 } })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => 0, 'b' => 2, 'c' => 3
        })
      end

      it 'accepts a nested _pat_obj' do

        r = @executor.launch(
          %q{
            _pat_obj
              a; a
              b; _pat_obj
                c; 1
                d; d
              e; e
          },
          payload: {
            'ret' => { 'a' => 0, 'b' => { 'c' => 1, 'd' => 2 }, 'e' => 3 }
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => 0, 'd' => 2, 'e' => 3
        })
      end

      it 'accepts a nested _pat_or' do

        r = @executor.launch(
          %q{
            _pat_obj
              a; a
              b; _pat_or
                11
                22
              c; c
          },
          payload: {
            'ret' => { 'a' => 0, 'b' => 11, 'c' => 2 }
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => 0, 'c' => 2
        })
      end

      it 'accepts a nested _pat_guard (match)' do

        r = @executor.launch(
          %q{
            _pat_obj
              b; _pat_guard b (> b 10)
          },
          payload: { 'ret' => { 'b' => 11 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'b' => 11 })
      end

      it 'accepts a nested _pat_guard (no match)' do

        r = @executor.launch(
          %q{
            _pat_obj
              b; _pat_guard b (> b 10)
          },
          payload: { 'ret' => { 'b' => 1 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end
  end
end

