
#
# specifying flor
#
# Sat Dec 26 10:37:45 JST 2015
#

require 'spec_helper'


def determine_title(radial, tree, line)

  title =
    radial.length > 31 ?
    "#{(radial[0, 31] + '...').inspect} l#{line}" :
    "#{radial.inspect} l#{line}"
  title =
    tree == nil ?
    "doesn't parse #{title}" :
    "parses #{title}"

  title
end

describe Flor::Radial do

  describe '.parse' do

    it 'tracks the origin of the string' do

      expect(
        Flor::Radial.parse('sequence timeout: 1d', 'var/lib/one.rad')
      ).to eq(
        [ 'sequence', { 'timeout' => '1d' }, 1, [], 'var/lib/one.rad' ]
      )
    end

    context 'core' do

      pe = lambda { |x| parse_expectation.call(x) }

      [
        [ '12[3', nil, __LINE__ ],

        [ 'sequence', [ 'sequence', {}, 1, [] ], __LINE__ ],

        [ "sequence\n" +
          "  participant 'bravo'",
          [ 'sequence', {}, 1, [
            [ 'participant', { '_0' => 'bravo' }, 2, [] ]
          ] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  participant 'alpha'\n" +
          "  concurrence\n" +
          "    participant 'bravo'\n" +
          "    participant 'charly'\n" +
          "  participant 'delta'",
          [ 'sequence', {}, 1, [
            [ 'participant', { '_0' => 'alpha' }, 2, [] ],
            [ 'concurrence', {}, 3, [
              [ 'participant', { '_0' => 'bravo' }, 4, [] ],
              [ 'participant', { '_0' => 'charly' }, 5, [] ]
            ] ],
            [ 'participant', { '_0' => 'delta' }, 6, [] ]
          ] ],
          __LINE__ ],

        [
          "iterate [\n" +
          "  1 2 3 ]\n" +
          "  bravo",
          [ 'iterate', { '_0' => [ 1, 2, 3 ] }, 1, [
            [ 'bravo', {}, 3, [] ]
          ] ],
          __LINE__ ],

        [
          "participant charly a: 0, b: one c: true, d: [ four ]",
          [ 'participant', {
            '_0' => 'charly',
            'a' => 0, 'b' => 'one', 'c' => true, 'd' => [ 'four' ]
          }, 1, [] ],
          __LINE__ ],

        [
          "participant charly,\n" +
          "  aa: 0,\n" +
          "  bb: one,\n" +
          "  cc: true,\n" +
          "  dd: [ four ]",
          [ 'participant', {
            '_0' => 'charly',
            'aa' => 0, 'bb' => 'one', 'cc' => true, 'dd' => [ 'four' ]
          }, 1, [] ],
          __LINE__ ],

        [
          "participant charly, # charlie\n" +
          "  aa: 0, # zero\n" +
          "  bb: one, # one\n" +
          "  cc: true, # three\n" +
          "  dd: [ four ] # four",
          [ 'participant', {
            '_0' => 'charly',
            'aa' => 0, 'bb' => 'one', 'cc' => true, 'dd' => [ 'four' ]
          }, 1, [] ],
          __LINE__ ],

        [
          "participant charly, # charlie\n" +
          "  aa:     # zero\n" +
          "    0,    // zero indeed\n" +
          "  bb: one # one\n",
          [ 'participant', {
            '_0' => 'charly', 'aa' => 0, 'bb' => 'one'
          }, 1, [] ],
          __LINE__ ],

        [
          "nada aa bb d: 2, e: 3",
          [ 'nada', { '_0' => 'aa', '_1' => 'bb', 'd' => 2, 'e' => 3 }, 1, [] ],
          __LINE__ ],

        [
          "nada d: 0 e: 1 aa bb",
          [ 'nada', { 'd' => 0, 'e' => 1, '_2' => 'aa', '_3' => 'bb' }, 1, [] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  participant toto # blind\n" +
          "  participant tutu # deaf",
          [ 'sequence', {}, 1, [
            [ 'participant', { '_0' => 'toto' }, 2, [] ],
            [ 'participant', { '_0' => 'tutu' }, 3, [] ]
          ] ],
          __LINE__ ],

        [
          "# Tue Jul  8 05:50:28 JST 2014\n" +
          "sequence\n" +
          "  participant toto",
          [ 'sequence', {}, 2, [
            [ 'participant', { '_0' => 'toto' }, 3, [] ]
          ] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  git://github.com/flon-io/tst x b: 0\n",
          #"  git://github.com/flon-io/tst x y a: 0, b: 1\n",
          #"  git://github.com/flon-io/tst a: 0, b: 1\n",
          [ 'sequence', {}, 1, [
            [ 'git://github.com/flon-io/tst', { '_0' => 'x', 'b' => 0 }, 2, [] ]
          ] ],
          __LINE__ ],

        [
          "$(a)\n" +
          "  b $(c) $(d): e f: $(g) $(h)$(i)\n",
          [ '$(a)', {}, 1, [
            [ 'b', {
              '_0' => '$(c)', '$(d)' => 'e', 'f' => '$(g)', '_3' => '$(h)$(i)'
            }, 2, [] ]
          ] ],
          __LINE__ ],

        [
          "invoke a b: c:y\n",
          [ 'invoke', { '_0' => 'a', 'b' => 'c:y' }, 1, [] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  + a b \n" +
          "  - a b \n" +
          "  a + b\n" +
          "  a - b\n" +
          "  * c d\n" +
          "  / c d\n" +
          "  c * d\n" +
          "  c / d\n",
          [ 'sequence', {}, 1, [
            [ '+', { '_0' => 'a', '_1' => 'b' }, 2, [] ],
            [ '-', { '_0' => 'a', '_1' => 'b' }, 3, [] ],
            [ 'a', { '_0' => '+', '_1' => 'b' }, 4, [] ],
            [ 'a', { '_0' => '-', '_1' => 'b' }, 5, [] ],
            [ '*', { '_0' => 'c', '_1' => 'd' }, 6, [] ],
            [ '/', { '_0' => 'c', '_1' => 'd' }, 7, [] ],
            [ 'c', { '_0' => '*', '_1' => 'd' }, 8, [] ],
            [ 'c', { '_0' => '/', '_1' => 'd' }, 9, [] ]
          ] ],
          __LINE__ ],

        [
          "=~\n" +
          "  toto\n" +
          "  to$\n",
          [ '=~', {}, 1, [
            [ 'toto', {}, 2, [] ],
            [ 'to$', {}, 3, [] ]
          ] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  3\n" +
          "  null\n" +
          "  quatre\n",
          [ 'sequence', {}, 1, [
            [ 'val', { '_0' => 3 }, 2, [] ],
            [ 'val', { '_0' => nil }, 3, [] ],
            [ 'quatre', {}, 4, [] ]
          ] ],
          __LINE__ ],

        [
          "set f.a: 1",
          [ 'set', { 'f.a' => 1 }, 1, [] ],
          __LINE__ ]

      ].each do |radial, tree, line|
        it(determine_title(radial, tree, line)) do
          expect(Flor::Radial.parse(radial)).to eq(tree)
        end
      end
    end

    context 'parenthesis' do

      [
        [
          "if (a > b)\n",
          [ 'if', {
            '_0' => [ 'a', { '_0' => '>', '_1' => 'b' }, 1, [] ]
          }, 1, [] ],
          __LINE__ ],

        [
          "(a > 0) and (b > 1)\n",
          [
            [ 'a', { '_0' => '>', '_1' => 0 }, 1, [] ],
            { '_0' => 'and',
              '_1' => [ 'b', { '_0' => '>', '_1' => 1 }, 1, [] ] },
            1,
            []
          ],
          __LINE__ ],

        [
          "if (a > $(b)$(c))\n",
          [ 'if', {
            '_0' => [ 'a', { '_0' => '>', '_1' => "$(b)$(c)" }, 1, [] ]
          }, 1, [] ],
          __LINE__ ],

        [
          "if ( # really?\n" +
          "  a > b)\n",
          [ 'if', {
            '_0' => [ 'a', { '_0' => '>', '_1' => 'b' }, 2, [] ]
          }, 1, [] ],
          __LINE__ ],

        [
          "if ( // really?\n" +
          "   a > b)\n",
          [ 'if', {
            '_0' => [ 'a', { '_0' => '>', '_1' => 'b' }, 2, [] ]
          }, 1, [] ],
          __LINE__ ],

        [
          "task Alan value: (1 + 2)",
          [ 'task', {
            '_0' => 'Alan',
            'value' => [
              [ 'val', { '_0'=>1 }, 1, [] ],
              { '_0' => '+', '_1' => 2 }, 1, [] ]
            }, 1, [] ],
          __LINE__ ],

        [
          "sub (1 + 2)",
          [ 'sub', {
            '_0' => [
              [ 'val', { '_0' => 1 }, 1, [] ], { '_0' => '+', '_1' => 2 }, 1, []
            ]
          }, 1, [] ],
          __LINE__ ]

      ].each do |radial, tree, line|
        it(determine_title(radial, tree, line)) do
          expect(Flor::Radial.parse(radial)).to eq(tree)
        end
      end
    end

    context 'regexes' do

      [
        [
          "sequence\n" +
          "  =~ ab /c d/\n",
          [ 'sequence', {}, 1, [
            [ '=~', { '_0' => 'ab', '_1' => /c d/ }, 2, [] ]
          ] ],
          __LINE__ ],

        [
          "sequence\n" +
          "  =~ ab /c, d/i\n",
          [ 'sequence', {}, 1, [
            [ '=~', { '_0' => 'ab', '_1' => /c, d/i }, 2, [] ]
          ] ],
          __LINE__ ]

      ].each do |radial, tree, line|
        it(determine_title(radial, tree, line)) do
          expect(Flor::Radial.parse(radial)).to eq(tree)
        end
      end
    end
  end
end

