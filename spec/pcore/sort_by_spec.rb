
#
# specifying flor
#
# Sat Nov 24 15:35:37 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sort_by' do

    it 'maps and sorts' do

      r = @executor.launch(
        %q{
          sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 3 } ]
            def e
              e.n
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 3 }, { 'n' => 4 } ])
    end

    it 'maps and sorts (coll then fun)' do

      r = @executor.launch(
        %q{
          sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ] (def e \ e.n)
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end

    it 'maps and sorts (fun then coll)' do

      r = @executor.launch(
        %q{
          sort_by (def e \ e.n) [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end

    it 'maps and sorts (incoming collection)' do

      r = @executor.launch(
        %q{
          [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
          sort_by (def e \ e.n)
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end

    it 'fails if given no collection' do

      r = @executor.launch( %q{
        1
        sort_by (def e \ e)
      })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('collection not given to "sort_by"')
    end

    it 'fails if given no function' do

      r = @executor.launch( %q{ sort_by [] })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('function not given to "sort_by"')
    end

    it 'sorts arrays of numbers' do

      r = @executor.launch(
        %q{
          [ { n: 1.1 } { n: 1.0 } { n: 1.4 } { n: 0 } ]
          sort_by (def e \ e.n)
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1.0 }, { 'n' => 1.1 }, { 'n' => 1.4 } ])
    end

    it 'sorts arrays of strings' do

      r = @executor.launch(
        %q{
          [ { s: 'zzz' } { s: 'xxx' } { s: 'yyy' } { s: 'aaa' } ]
          sort_by (def e \ e.s)
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 's' => 'aaa' }, { 's' => 'xxx' }, { 's' => 'yyy' }, { 's' => 'zzz' } ])
    end

    it 'sorts arrays of arrays' do

      r = @executor.launch(
        %q{
          [ [ 'zzz' ] [ 'aaa' ] ]
          sort_by (def e \ e)
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ [ 'aaa' ], [ 'zzz' ] ])
    end

    it 'sorts arrays of objects' do

      r = @executor.launch(
        %q{
          [ { s: 'zzz' } { s: 'xxx' } { s: 'yyy' } { s: 'aaa' } ]
          sort_by (def e \ e)
        })

      expect(r).to have_terminated_as_point

      expect(r['payload']['ret']).to eq([
       { 's' => 'aaa' }, { 's' => 'xxx' }, { 's' => 'yyy' }, { 's' => 'zzz' } ])
    end

    it 'sorts heterogeneous arrays (as JSON)' do

      r = @executor.launch(
        %q{
          sort_by
            [ { d: 'zzz' } { d: -1.5 } { d: true } { d: null } { d: 'alpha' } ]
            (def e \ e.d)
        })

      expect(r).to have_terminated_as_point

      expect(
        r['payload']['ret']
      ).to eq(
        [ -1.5, 'alpha', nil, true, 'zzz' ]
          .map { |e| { 'd' => e } }
      )
    end

    it 'sorts objects' do

      r = @executor.launch(
        %q{
          sort_by
            o
            (def key val \ val.age)
        },
        vars: { 'o' => {
          'ceo' => { 'name' => 'Elie', 'age' => 50 },
          'cto' => { 'name' => 'Theo', 'age' => 30 },
          'cfo' => { 'name' => 'Fred', 'age' => 45 },
          'cio' => { 'name' => 'Ines', 'age' => 28 } } })

      expect(r).to have_terminated_as_point

      expect(
        r['payload']['ret']
      ).to eq({
        'cio' => { 'name' => 'Ines', 'age' => 28 },
        'cto' => { 'name' => 'Theo', 'age' => 30 },
        'cfo' => { 'name' => 'Fred', 'age' => 45 },
        'ceo' => { 'name' => 'Elie', 'age' => 50 },
      })
    end
  end
end

