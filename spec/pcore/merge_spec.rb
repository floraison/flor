
#
# specifying flor
#
# Mon Oct  1 07:24:41 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

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
      "merge { a: 0 } { b: 1 } 'y' { c: 2 } tag: 'x' loose: true" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      '{ a: 0 }; merge { b: 1 } { c: 2 }' =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      'merge {}' => {},
      'merge { a: 0 }' => { 'a' => 0 },
      '{}; merge _' => {},
      '{ a: 0 }; merge _' => { 'a' => 0 },

      "merge [ 0 1 2 3 ] [ 'a' 'b' 'c' ]" =>
        [ 'a', 'b', 'c', 3 ],

      'merge []' => [],
      'merge [ 0 1 2 ]' => [ 0, 1, 2 ],
      '[]; merge _' => [],
      '[ 0 1 2 ]; merge _' => [ 0, 1, 2 ],

      '{ a: 0 }; merge { b: 1 }' =>
        { 'a' => 0, 'b' => 1 },
      '{ a: 0 }; merge { b: 1 } { c: 2 }' =>
        { 'b' => 1, 'c' => 2 },
      '{ a: 0 }; merge f.ret { b: 1 } { c: 2 }' =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      "[ 0 1 2 ]; merge [ 0 1 'deux' 'trois' ]" => [ 0, 1, 'deux', 'trois' ],
      "[ 0 1 2 ]; merge [ 0 1 'deux' 3 ]" => [ 0, 1, 'deux', 3 ],
      "[ 0 1 2 3 4 ]; merge [ 0 1 2 3 ] [ 0 'un' 2 ]" => [ 0, 'un', 2, 3 ],
      "[ 0 1 2 3 4 ]; merge f.ret [ 0 1 2 3 ] [ 0 'un' 2 ]" => [ 0, 'un', 2, 3, 4 ],
      "[ 0 1 2 3 4 ]; merge [ 0 1 2 3 ] [ 0 'un' 2 ] f.ret" => [ 0, 1, 2, 3, 4 ],
      "[ 0 ]; merge { a: 1 } { a: 'one' }" => { 'a' => 'one' },

    }.test_each(self)

    [

      "merge _",
      "merge null",
      "merge 0",
      "merge 'string'",
      "[]; merge 'string'",

    ].test_each_fail(self, 'found no array or object to merge')

    [

      "merge {} []",
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 }",
      "merge { a: 0 } { b: 1 } [ 2 ]",
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx'",

    ].test_each_fail(self, /\Afound a non-/)
  end
end

