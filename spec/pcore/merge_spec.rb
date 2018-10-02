
#
# specifying flor
#
# Mon Oct  1 07:24:41 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'merge' do

    {

      "merge { a: 0 b: 1 } { b: 'B' c: 'C' }" =>
        { 'a' => 0, 'b' => 'B', 'c' => 'C' },
      "merge { b: 'B' c: 'C' } { a: 0 b: 1 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 'C' },
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } lax: true" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } strict: false" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },
      "merge { a: 0 } { b: 1 } { c: 2 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx' loose: true" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      "{ a: 0 }; merge { b: 1 } { c: 2 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      "merge {}" => {},
      "merge { a: 0 }" => { 'a' => 0 },
      "{}; merge _" => {},
      "{ a: 0 }; merge _" => { 'a' => 0 },

      "merge [ 0 1 2 3 ] [ 'a' 'b' 'c' ]" =>
        [ 'a', 'b', 'c', 3 ],

      "merge []" => [],
      "merge [ 0 1 2 ]" => [ 0, 1, 2 ],
      "[]; merge _" => [],
      "[ 0 1 2 ]; merge _" => [ 0, 1, 2 ],

    }.each do |k, v|

      it "succeeds for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end

    [

      "merge _",
      "merge null",
      "merge 0",
      "merge 'string'",

    ].each do |c|

      it "fails (nothing to merge) for `#{c}`" do

        r = @executor.launch(c)

        expect(r['point']).to eq('failed')
        expect(r['error']['msg']).to eq('found no array or object to merge')
      end
    end

    [

      "merge {} []",
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 }",
      "merge { a: 0 } { b: 1 } [ 2 ]",
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx'",

    ].each do |c|

      it "fails (strict) for `#{c}`" do

        r = @executor.launch(c)

        expect(r['point']).to eq('failed')
        expect(r['error']['msg']).to match(/\Afound a non-/)
      end
    end
  end
end

