
#
# specifying flor
#
# Sat Jun 16 16:00:01 JST 2018
#

require 'spec_helper'

INDEX_ARR = %w[ a b c d e f g h i j k l m ]
INDEX_OBJ = Hash[*%w[ a A b B c C d D e E f F g G ]]


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'index' do

    context 'array' do

      {

        '1' => 'b',
        '14' => nil,
        '(-1)' => 'm',  # :-(
        '[ 1 ]' => [ 'b' ],
        '[ 1, 3 ]' => [ 'b', 'd' ],
        '[ 1, 14 ]' => [ 'b', nil ],
        '[ "*" ]' => INDEX_ARR,
        '[ 1, [ 2, 2 ], [ 3, 7, 2 ] ]' => %w[ b c d d f h ],
        '[ [ -4, 2 ] ]' => %w[ j k ],
        '[ [ -6, -3, 1 ] ]' => %w[ h i j k ],
        '[ [ -6, 0, -1 ] ]' => %w[ h g f e d c b a ],
        '[ [ -6, 0, -2 ] ]' => %w[ h f d b ],

        '"nada0"' => TypeError.new('cannot index array with key "nada0"'),
        '[ "nada1" ]' => TypeError.new('cannot index array with key "nada1"'),
        '[ /^a$/ ]' => TypeError.new('cannot index array with regex /^a$/'),

      }.each do |ind, exp|

        it "returns #{exp.inspect} for `index #{ind}`" do

          r = @executor.launch(
            %{
              f.a
              index #{ind}
            },
            payload: { 'a' => INDEX_ARR })

          if exp.is_a?(Exception)
            expect(r['point']).to eq('failed')
            expect(r['error']['kla']).to eq(exp.class.to_s)
            expect(r['error']['msg']).to eq(exp.message)
          else
            expect(r['point']).to eq('terminated')
            expect(r['payload']['ret']).to eq(exp)
          end
        end
      end
    end

    context 'object' do

      {

        '"a"' => 'A',
        '"z"' => nil,
        '[ "a" ]' => [ 'A' ],
        '[ "a", "g" ]' => [ 'A', 'G' ],
        '[ "a", "h" ]' => [ 'A', nil ],
        '[ "*" ]' => INDEX_OBJ.values,
        '[ /^[aces]$/ ]' => [ 'A', 'C', 'E' ],

      }.each do |ind, exp|

        it "returns #{exp.inspect} for `index #{ind}`" do

          r = @executor.launch(
            %{
              f.o
              index #{ind}
            },
            payload: { 'o' => INDEX_OBJ })

          if exp.is_a?(Exception)
            expect(r['point']).to eq('failed')
            expect(r['error']['kla']).to eq(exp.class.to_s)
            expect(r['error']['msg']).to eq(exp.message)
          else
            expect(r['point']).to eq('terminated')
            expect(r['payload']['ret']).to eq(exp)
          end
        end
      end
    end

    context 'pth tracking' do

      it 'adds to the local pth variable if present' do

        r = @executor.launch(
          %q{
            sequence vars: { pth: [] }
              f.o
              index 'a'
              index 'b'
          },
          payload: { 'o' => { 'a' => { 'b' => 'B' } } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('B')
        expect(r['vars']['pth']).to eq(%w[ a b ])
      end
    end
  end
end

