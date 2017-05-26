
#
# specifying flor
#
# Thu May 25 09:02:23 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_or' do

    [

      [ %q{ _pat_or _ }, 11, nil ],
      [ %q{ _pat_or \ 10 }, 11, nil ],
      [ %q{ _pat_or \ 11 }, 11, {} ],
      [ %q{ _pat_or \ 10; 11 }, 11, {} ],

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
            _pat_or
              _pat_arr
                a
                1
              _pat_arr
                1
                b
          },
          payload: { 'ret' => [ 1, 2 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'b' => 2 })
      end

      it 'accepts a nested _pat_arr (no match)' do

        r = @executor.launch(
          %q{
            _pat_or
              _pat_arr
                a
                1
              _pat_arr
                1
                b
          },
          payload: { 'ret' => [ 3, 2 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end

      it 'accepts a nested _pat_obj' do

        r = @executor.launch(
          %q{
            _pat_or
              _pat_obj
                a; 2
                b; b
              _pat_obj
                a; a
                b; 2
          },
          payload: { 'ret' => { 'a' => 1, 'b' => 2 } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'a' => 1 })
      end

      it 'accepts a nested _pat_or' do

        r = @executor.launch(
          %q{
            _pat_or
              _pat_or
                1
                2
              _pat_or
                3
                4
          },
          payload: { 'ret' => 4 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({})
      end

      it 'accepts a nested _pat_guard'
    end
  end
end

