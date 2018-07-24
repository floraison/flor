
#
# specifying flor
#
# Sat May 27 11:57:25 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_guard' do

    context '_pat_guard _' do

      it "doesn't match" do

        r = @executor.launch(
          %q{ _pat_guard _ },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context '_pat_guard {name}' do

      it 'binds' do

        r = @executor.launch(
          %q{ _pat_guard x },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'x' => 11 })
      end
    end

    context '_pat_guard {conditional}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard true },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({})
      end

      it 'does not match' do

        r = @executor.launch(
          %q{ _pat_guard false },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context '_pat_guard {name} {pattern}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard x (_pat_or 1 11) },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'x' => 11 })
      end

      it 'does not match' do

        r = @executor.launch(
          %q{ _pat_guard x (_pat_or 1 11) },
          payload: { 'ret' => 22 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end

      it 'passes on the binding from the sub-pattern' do

        r = @executor.launch(
          %q{ _pat_guard a (_pat_arr \ _; a1; _) },
          payload: { 'ret' => [ 1, 2, 3 ] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'a' => [ 1, 2, 3 ], 'a1' => 2
        })
      end

      it 'gets rid of unnecessary parent _pat_arr underscores' do

        r = @executor.launch(
          %q{ _pat_guard a___ (_pat_or [ 0 1 ] [ 1 2 ]) },
          payload: { 'ret' => [ 1, 2 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'a' => [ 1, 2 ] })
      end
    end

    context '_pat_guard {name} {conditional}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard x true },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'x' => 11 })
      end

      it 'does not match' do

        r = @executor.launch(
          %q{ _pat_guard x false },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end

      it 'passes the name->val to the conditional' do

        r = @executor.launch(
          %q{ _pat_guard x (x > 3) },
          payload: { 'ret' => 4 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'x' => 4 })
      end
    end

    context '_pat_guard {name} {conditional} {pattern}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard x ((length x) > 3) (_pat_arr \ a; ___; b) },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5 ] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'x' => [ 0, 1, 2, 3, 4, 5 ], 'a' => 0, 'b' => 5
        })
      end

      it 'does not match' do

        r = @executor.launch(
          %q{ _pat_guard x ((length x) > 3) (_pat_arr \ a; ___; b) },
          payload: { 'ret' => [ 0, 1 ] })

        expect(r['point']).to eq('terminated')

        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context '_pat_guard {name} {pattern} {conditional}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard x (_pat_arr \ a; ___; b) (> b 4) },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5 ] })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'x' => [ 0, 1, 2, 3, 4, 5 ], 'a' => 0, 'b' => 5
        })
      end

      it 'does not match' do

        r = @executor.launch(
          %q{ _pat_guard x (_pat_arr \ a; ___; b) (> b 7) },
          payload: { 'ret' => [ 0, 1, 2, 3, 4, 5 ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context '_pat_guard {name} {_pat_regex}' do

      it 'matches' do

        r = @executor.launch(
          [ '_pat_guard', [
            [ '_att', [ [ 'x', [], 1 ] ] ],
            [ '_pat_regex', [ [ '_sqs', '^([a-z]{0,3})\d*$', 1 ] ], 1 ]
          ], 1 ],
          payload: { 'ret' => 'abc123' })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['_pat_binding']
        ).to eq({
          'match' => [ 'abc123', 'abc' ],
          'matched' => 'abc123',
          'x' => 'abc123',
          'x__match' => [ 'abc123', 'abc' ],
          'x__matched' => 'abc123'
        })
      end

      it 'does not match'
    end
  end
end

