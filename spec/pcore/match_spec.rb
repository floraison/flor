
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

      it "doesn't patternize if suffixed with !" do

        r = @executor.launch(
          %q{
            match [ 1 2 ]
              [ 1 _ ] !; 'a'
              [ 1 2 ] !; 'b'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('b')
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

      it "doesn't match" do

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

      it "respects quoted keys" do

        r = @executor.launch(
          %q{
            set a 'A'
            set b 'B'
            match { 'a': 1, 'b': 2 }
              { 'a': 1, 'b': 2 }; 'match'
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

      it "doesn't patternize if suffixed with !" do

        r = @executor.launch(
          %q{
            match { 'a': 1, 'b': 2 }
              { a: 1 } !; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end
    end

    context 'or' do

      it 'matches (infix)' do

        r = @executor.launch(
          %q{
            match 11
              22 or 11 or 9; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match')
      end

      it "doesn't match (infix)" do

        r = @executor.launch(
          %q{
            match 12
              11 or 22 or 33; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end

      it "doesn't patternize if suffixed with !" do

        r = @executor.launch(
          %q{
            match 2
              or ! 1 2; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end

      it "doesn't patternize if suffixed with ! (or!)" do

        r = @executor.launch(
          %q{
            match 2
              or! 1 2; 'match'
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end
    end

    context 'guards' do

      it 'matches' do

        r = @executor.launch(
          %q{
            match [ 1 2 3 4 ]
              (guard a ((length a) == 3)); "l3"
              (guard a ((length a) == 4)); "l4"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('l4')
      end

      it "doesn't match" do

        r = @executor.launch(
          %q{
            match [ 1 2 ]
              (guard a ((length a) == 3)); "l3"
              (guard a ((length a) == 4)); "l4"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end

      it 'matches with a nested or (_pat_or)'# do
#
#        r = @executor.launch(
#          %q{
#            match [ 1 2 3 4 ]
#              (guard a (or [ a0 __5 ] [ a0 a1 ___ ]) (a1 > 10)); "A:$(a0):$(a1)"
#              (guard a (or [ a0 __5 ] [ a0 a1 ___ ])); "B:$(a0):$(a1)"
#              else; 'no-match'
#          })
#
#        expect(r['point']).to eq('terminated')
#        expect(r['payload']['ret']).to eq('a:1:')
#      end

      it 'matches with a nested or! (or)' do

        r = @executor.launch(
          %q{
            match [ 1 2 3 4 ]
              (guard a (or! ((length a) == 3) ((length a) == 4))); "match"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match')
      end
    end

    context 'bind' do

      it 'matches' do

        r = @executor.launch(
          %q{
            match [ 1 3 ]
              [ 1 (bind y (or 2 3)) ]; "match y:$(y)"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match y:3')
      end

      it "doesn't match" do

        r = @executor.launch(
          %q{
            match [ 1 4 ]
              [ 1 (bind y (or 2 3)) ]; "match y:$(y)"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end
    end

    context 'deep' do

      it 'matches' do

        ret = {}
        ret['player'] = { 'name' => 'Eldred', 'number' => 55 }

        r = @executor.launch(
          %q{
            match
              { player.name: 'Eldred' }; 'USA'
              { player.name: 'Johnson' }; 'USA'
              else; 'Japan'
          },
          payload: { 'ret' => ret })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('USA')
      end
    end

    context 'regexes' do

      it 'matches' do

        ret = {}
        ret['player'] = { 'name' => 'Johnson', 'number' => 42 }

        r = @executor.launch(
          %q{
            match
              { player.name: 'Eldred' }; 'red'
              { player.name: /^(J.+)son$/ }; match.1
              else; 'else'
          },
          payload: { 'ret' => ret })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('John')
      end

      it "doesn't match" do

        ret = {}
        ret['player'] = { 'name' => 'Gregson', 'number' => 99 }

        r = @executor.launch(
          %q{
            match
              { player.name: 'Eldred' }; 'red'
              { player.name: /^J.+son$/ }; 'son'
              else; 'else'
          },
          payload: { 'ret' => ret })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('else')
      end

      it 'binds' do

        r = @executor.launch(
          %q{
            match [ 1 'bravo' ]
              [ 1 (bind a (/^a.+/)) ]; "match a:$(a)"
              [ 1 (bind b (/^b(.+)/)) ]; "match b:$(b):$(b_match.1)"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('match b:bravo:ravo')
      end

      it 'does not bind' do

        r = @executor.launch(
          %q{
            match [ 1 'charly' ]
              [ 1 (bind a (/^a.+/)) ]; "match a:$(a)"
              [ 1 (bind b (/^b.+/)) ]; "match b:$(b)"
              else; 'no-match'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('no-match')
      end
    end
  end
end

