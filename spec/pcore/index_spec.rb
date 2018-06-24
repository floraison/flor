
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

        '1' => {
          ret: 'b', pat: [ 1 ] },
        '14' => {
          ret: nil, pat: [ 14 ] },
        '(-1)' => {
          ret: 'm', pat: [ -1 ] }, # :-(
        '[ 1 ]' => {
          ret: [ 'b' ], pat: [ [ 1 ] ] },
        '[ 1, 3 ]' => {
          ret: [ 'b', 'd' ], pat: [ [ 1, 3 ] ] },
        '[ 1, 14 ]' => {
          ret: [ 'b', nil ], pat: [ [ 1, 14 ] ] },
        '[ "*" ]' => {
          ret: INDEX_ARR, pat: [ [ '*' ] ] },
        '[ 1, [ 2, 2 ], [ 3, 7, 2 ] ]' => {
          ret: %w[ b c d d f h ], pat: [ [ 1, [ 2, 2 ], [ 3, 7, 2 ] ] ] },
        '[ [ -4, 2 ] ]' => {
          ret: %w[ j k ], pat: [ [ [ -4, 2 ] ] ] },
        '[ [ -6, -3, 1 ] ]' => {
          ret: %w[ h i j k ], pat: [ [ [ -6, -3, 1 ] ] ] },
        '[ [ -6, 0, -1 ] ]' => {
          ret: %w[ h g f e d c b a ], pat: [ [ [ -6, 0, -1 ] ] ] },
        '[ [ -6, 0, -2 ] ]' => {
          ret: %w[ h f d b ], pat: [ [ [ -6, 0, -2 ] ] ] },

        '"nada0"' =>
          TypeError.new('cannot index array with key "nada0"'),
        '[ "nada1" ]' =>
          TypeError.new('cannot index array with key "nada1"'),
        '[ /^a$/ ]' =>
          TypeError.new('cannot index array with regex /^a$/'),

      }.each do |ind, exp|

        it "returns #{(exp.is_a?(Exception) ? exp : exp[:ret]).inspect} for `index #{ind}`" do

          r = @executor.launch(
            %{
              path
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
            expect(r['payload']['ret']).to eq(exp[:ret])
            expect(r['payload']['pat']).to eq(exp[:pat])
          end
        end
      end
    end

    context 'object' do

      {

        '"a"' => {
          ret: 'A', pat: [ 'a' ] },
        '"z"' => {
          ret: nil, pat: [ 'z' ] },
        '[ "a" ]' => {
          ret: [ 'A' ], pat: [ [ 'a' ] ] },
        '[ "a", "g" ]' => {
          ret: [ 'A', 'G' ], pat: [ [ 'a', 'g' ] ] },
        '[ "a", "h" ]' => {
          ret: [ 'A', nil ], pat: [ [ 'a', 'h' ] ] },
        '[ "*" ]' => {
          ret: INDEX_OBJ.values, pat: [ [ '*' ] ] },
        '[ /^[aces]$/ ]' => {
          ret: [ 'A', 'C', 'E' ], pat: [ [ 'a', 'c', 'e' ] ] },

      }.each do |ind, exp|

        it "returns #{(exp.is_a?(Exception) ? exp : exp[:ret]).inspect} for `index #{ind}`" do

          r = @executor.launch(
            %{
              path
                f.o
                index #{ind}
            },
            payload: { 'o' => INDEX_OBJ })

          #if exp.is_a?(Exception)
          #  expect(r['point']).to eq('failed')
          #  expect(r['error']['kla']).to eq(exp.class.to_s)
          #  expect(r['error']['msg']).to eq(exp.message)
          #else
          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(exp[:ret])
          expect(r['payload']['pat']).to eq(exp[:pat])
          #end
        end
      end
    end

    context 'path tracking' do

      it 'returns a "pat" field' do

        r = @executor.launch(
          %q{
            path
              f.o
              index 'a'
              index 'b'
          },
          payload: { 'o' => { 'a' => { 'b' => 'B' } } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('B')
        expect(r['payload']['pat']).to eq(%w[ a b ])
      end

      it 'returns a "pat" composite field' do

        r = @executor.launch(
          %q{
            path
              f.o
              index [ 'a', 'b' ]
              index 'c'
          },
          payload: {
            'o' => { 'a' => { 'c' => 'C0' }, 'b' => { 'c' => 'C1' } } })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ 'C0', 'C1' ])
        expect(r['payload']['pat']).to eq([ [ 'a', 'b' ], 'c' ])
      end
    end
  end
end

