
#
# specifying flor
#
# Wed May 17 13:07:53 JST 2017  Basset Café
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'match' do

    it 'returns immediately if empty' do

      r = @executor.launch(
        %q{
          match _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'overlaps "case"' do

      r = @executor.launch(
        %q{
          set a 1
          match a
            0; "zero"
            1; "one"
            2; "two"
            else; "more than two"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('one')
    end

    it 'understands else' do

      r = @executor.launch(
        %q{
          set a 7
          match a
            0; "zero"
            1; "one"
            else; "more than one"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('more than one')
    end

    it 'treats a lonely wildcard as a else' do

      r = @executor.launch(
        %q{
          match 7
            0; "zero"
            _; "caught"
            1; "one"
            else; "more than one"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('caught')
    end

    it "doesn't mind having nothing but a \"else\"" do

      r = @executor.launch(
        %q{
          match 7
            else; "more than one"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('more than one')
    end

    it 'considers f.ret by default' do

      r = @executor.launch(
        %q{
          7
          match
            0; 'zero'
            7; 'seven'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('seven')
    end

    context 'arrays' do

      FizzBuzz =
        %q{
          match [ (% i 3) (% i 5) ]
            [ 0 0 ]; 'FizzBuzz'
            [ 0 _ ]; 'Fizz'
            [ _ 0 ]; 'Buzz'
            else; i
        }

      [
        [ 1, 1 ],
        [ 3, 'Fizz' ],
        [ 4, 4 ],
        [ 5, 'Buzz' ],
        [ 15, 'FizzBuzz' ]
      ].each do |i, expected|

        it "goes #{expected} for #{i}" do

          r = @executor.launch(FizzBuzz, vars: { 'i' => i })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(expected)
        end
      end

      it 'uses the bindings as vars in the then-branch' do

        r = @executor.launch(
          %q{
            match [ 1 2 ]
              [ 0 0 ]; 'zero'
              [ 1 b ]; b
              [ _ 2 ]; 'two'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(2)
      end
    end

    context 'objects' do

      it 'matches' do

        r = @executor.launch(
          %q{
            match { 'a': 1, 'b': 2 }
              { a: 1 }; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match')
      end

      it 'may not match' do

        r = @executor.launch(
          %q{
            match { 'a': 1, 'b': 2 }
              { c: 1 }; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end

      it "respects the `quote: 'keys'`" do

        r = @executor.launch(
          %q{
            set a 'A'
            set b 'B'
            match { 'a': 1, 'b': 2 }
              { a: 1, b: 2 } quote: 'keys'; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match')
      end

      it 'respects `only`' do

        r = @executor.launch(
          %q{
            match { 'a': 1, 'b': 2 }
              { a: 1 } only; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end
    end

    context 'guards' do

      it 'accepts guards'
    end
  end
end

