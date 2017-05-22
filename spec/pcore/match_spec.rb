
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

  # breaks apart because array parsing is too greedy somehow
  #
  # using "_arr" (avoid syntaxic sugar) is a solution
  #
#      it 'destructures arrays' do
#
#        r = @executor.launch(
#          %q{
#            for-each a
#              def i
#                push l
#                  _arr
#                    i
#                    match [ (% i 3) (% i 5) ]
#                      [ 0 0 ] 'FizzBuzz'
#                      [ 0 _ ] 'Fizz'
#                      [ _ 0 ] 'Buzz'
#                      else i
#          },
#          vars: { 'a' => (1..17).to_a, 'l' => [] })
#
#        expect(r['point']).to eq('terminated')
##        expect(r['payload']['ret']).to eq('caught')
#        expect(r['vars']['l']).to eq(:xxx)
#      end
    end

    context 'objects' do

      it 'matches'
    end

    context 'guards' do

      it 'accepts guards'
    end
  end
end

