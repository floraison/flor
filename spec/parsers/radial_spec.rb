
#
# specifying flor
#
# Sat Dec 26 10:37:45 JST 2015
#

require 'spec_helper'


describe Flor::Radial do

  describe '.parse' do

    [
      [ '12[3', nil, __LINE__ ],

      [ 'sequence', [ 'sequence', {}, 1, [] ], __LINE__ ],

      [ "sequence\n" +
        "  participant 'bravo'",
        [ 'sequence', {}, 1, [
          [ 'participant', { '_0' => 'bravo' }, 2, [] ]
        ] ],
        __LINE__ ]

    ].each do |radial, tree, line|

      title =
        radial.length > 35 ?
        "#{(radial[0, 35] + '...').inspect} l#{line}" :
        "#{radial.inspect} l#{line}"
      title =
        tree == nil ?
        "doesn't parse #{title}" :
        "parses #{title}"

      it(title) do

        expect(Flor::Radial.parse(radial)).to eq(tree)
      end
    end

    it 'tracks the origin of the string' do

      expect(
        Flor::Radial.parse('sequence timeout: 1d')
      ).to eq(
        [ 'sequence', { 'timeout' => '1d' }, 1, [], 'var/lib/one.rad' ]
      )
    end
  end
end

#   it "parses a tree of lines"
#   {
#     v = fdja_dparse_radial(
#       "sequence\n"
#       "  participant 'alpha'\n"
#       "  concurrence\n"
#       "    participant 'bravo'\n"
#       "    participant 'charly'\n"
#       "  participant 'delta'"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ sequence, {}, 1, [ "
#         "[ participant, { _0: alpha }, 2, [] ], "
#         "[ concurrence, {}, 3, [ "
#           "[ participant, { _0: bravo }, 4, [] ], "
#           "[ participant, { _0: charly }, 5, [] ] "
#         "] ], "
#         "[ participant, { _0: delta }, 6, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts json/djan as first attribute"
#   {
#     v = fdja_dparse_radial(
#       "iterate [\n"
#       "  1 2 3 ]\n"
#       "  bravo"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ iterate, { _0: [ 1, 2, 3 ] }, 1, [ "
#         "[ bravo, {}, 3, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts attributes"
#   {
#     v = fdja_dparse_radial(
#       "participant charly a: 0, b: one c: true, d: [ four ]"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ participant, { "
#         "_0: charly, "
#         "a: 0, "
#         "b: one, "
#         "c: true, "
#         "d: [ four ] "
#       "}, 1, [] ]"
#     );
#   }
#
#   it "accepts attributes (and some newlines)"
#   {
#     v = fdja_dparse_radial(
#       "participant charly,\n"
#       "  aa: 0,\n"
#       "  bb: one,\n"
#       "  cc: true,\n"
#       "  dd: [ four ]"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ participant, { "
#         "_0: charly, "
#         "aa: 0, "
#         "bb: one, "
#         "cc: true, "
#         "dd: [ four ] "
#       "}, 1, [] ]"
#     );
#   }
#
#   it "accepts comments in the attributes"
#   {
#     v = fdja_dparse_radial(
#       "participant charly, # charlie\n"
#       "  aa: 0, # zero\n"
#       "  bb: one, # one\n"
#       "  cc: true, # three\n"
#       "  dd: [ four ] # four"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ participant, { "
#         "_0: charly, "
#         "aa: 0, "
#         "bb: one, "
#         "cc: true, "
#         "dd: [ four ] "
#       "}, 1, [] ]"
#     );
#   }
#
#   it "accepts comments in the attributes (after the colon)"
#   {
#     v = fdja_dparse_radial(
#       "participant charly, # charlie\n"
#       "  aa:     # zero\n"
#       "    0,    // zero indeed\n"
#       "  bb: one # one\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ participant, { "
#         "_0: charly, "
#         "aa: 0, "
#         "bb: one "
#       "}, 1, [] ]"
#     );
#   }
#
#   it "accepts unkeyed attributes"
#   {
#     v = fdja_dparse_radial("nada aa bb d: 2, e: 3");
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ nada, { _0: aa, _1: bb, d: 2, e: 3 }, 1, [] ]");
#   }
#
#   it "preserves the attribute order"
#   {
#     v = fdja_dparse_radial("nada d: 0 e: 1 aa bb");
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ nada, { d: 0, e: 1, _2: aa, _3: bb }, 1, [] ]");
#   }
#
#   it "accepts comments at the end of the radial lines"
#   {
#     v = fdja_dparse_radial(
#       "sequence\n"
#       "  participant toto # blind\n"
#       "  participant tutu # deaf"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ sequence, {}, 1, [ "
#         "[ participant, { _0: toto }, 2, [] ], "
#         "[ participant, { _0: tutu }, 3, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts comments before the radial lines"
#   {
#     v = fdja_dparse_radial(
#       "# Tue Jul  8 05:50:28 JST 2014\n"
#       "sequence\n"
#       "  participant toto"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ sequence, {}, 2, [ "
#         "[ participant, { _0: toto }, 3, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts words as rad names"
#   {
#     v = fdja_dparse_radial(
#       "sequence\n"
#       "  git://github.com/flon-io/tst x b: 0\n"
#       //"  git://github.com/flon-io/tst x y a: 0, b: 1\n"
#       //"  git://github.com/flon-io/tst a: 0, b: 1\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ sequence, {}, 1, [ "
#         "[ git://github.com/flon-io/tst, { _0: x, b: 0 }, 2, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts the $(dollar) stuff"
#   {
#     v = fdja_dparse_radial(
#       "$(a)\n"
#       "  b $(c) $(d): e f: $(g) $(h)$(i)\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ $(a), {}, 1, ["
#         " [ b, { _0: $(c), $(d): e, f: $(g), _3: $(h)$(i) }, 2, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts ':' in symbol values (not symbol keys)"
#   {
#     v = fdja_dparse_radial(
#       "invoke a b: c:y\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ invoke, { _0: a, b: c:y }, 1, [] ]"
#     );
#   }
#
#   it "accepts arithmetical signs as symbols"
#   {
#     v = fdja_dparse_radial(
#       "sequence\n"
#       "  + a b \n"
#       "  - a b \n"
#       "  a + b\n"
#       "  a - b\n"
#       "  * c d\n"
#       "  / c d\n"
#       "  c * d\n"
#       "  c / d\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ sequence, {}, 1, [ "
#         "[ +, { _0: a, _1: b }, 2, [] ], "
#         "[ -, { _0: a, _1: b }, 3, [] ], "
#         "[ a, { _0: +, _1: b }, 4, [] ], "
#         "[ a, { _0: -, _1: b }, 5, [] ], "
#         "[ *, { _0: c, _1: d }, 6, [] ], "
#         "[ /, { _0: c, _1: d }, 7, [] ], "
#         "[ c, { _0: *, _1: d }, 8, [] ], "
#         "[ c, { _0: /, _1: d }, 9, [] ] "
#       "] ]"
#     );
#   }
#
#   it "accepts dollar at the end of a symbol"
#   {
#     v = fdja_dparse_radial(
#       "=~\n"
#       "  toto\n"
#       "  to$\n"
#     );
#
#     ensure(v != NULL);
#
#     ensure(fdja_tod(v) ===f ""
#       "[ =~, {}, 1, [ "
#         "[ toto, {}, 2, [] ], "
#         "[ to$, {}, 3, [] ] "
#       "] ]"
#     );
#   }
#
#   context "single values"
#   {
#     it "accepts single values as radial lines"
#     {
#       v = fdja_dparse_radial(
#         "sequence\n"
#         "  3\n"
#         "  null\n"
#         "  quatre\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ sequence, {}, 1, [ "
#           "[ val, { _0: 3 }, 2, [] ], "
#           "[ val, { _0: null }, 3, [] ], "
#           "[ quatre, {}, 4, [] ] "
#         "] ]"
#       );
#     }
#   }
#
#   context "and () groups"
#   {
#     it "reads '(' groups"
#     {
#       v = fdja_dparse_radial(
#         "if (a > b)\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ if, { _0: [ a, { _0: >, _1: b }, 1, [] ] }, 1, [] ]"
#       );
#     }
#
#     it "accepts '(' groups as head"
#     {
#       v = fdja_dparse_radial(
#         "(a > 0) and (b > 1)\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ "
#           "[ a, { _0: >, _1: 0 }, 1, [] ], "
#           "{ _0: and, _1: [ b, { _0: >, _1: 1 }, 1, [] ] }, "
#           "1, "
#           "[] "
#         "]"
#       );
#     }
#
#     it "plays well with $(dollar)"
#     {
#       v = fdja_dparse_radial(
#         "if (a > $(b)$(c))\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ if, { _0: [ a, { _0: >, _1: $(b)$(c) }, 1, [] ] }, 1, [] ]"
#       );
#     }
#
#     it "accepts # eol comments"
#     {
#       v = fdja_dparse_radial(
#         "if ( # really?\n"
#         "   a > b)\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ if, { _0: [ a, { _0: >, _1: b }, 2, [] ] }, 1, [] ]"
#       );
#     }
#
#     it "accepts // eol comments"
#     {
#       v = fdja_dparse_radial(
#         "if ( // really?\n"
#         "   a > b)\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ if, { _0: [ a, { _0: >, _1: b }, 2, [] ] }, 1, [] ]"
#       );
#     }
#   }
#
#   context "and // regexes"
#   {
#     it "accepts /.../ regexes"
#     {
#       v = fdja_dparse_radial(
#         "sequence\n"
#         "  =~ ab /c d/\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ sequence, {}, 1, [ "
#           "[ =~, { _0: ab, _1: \"/c d/\" }, 2, [] ] "
#         "] ]"
#       );
#
#       expect(fdja_l(v, "3.0.1._1")->type c== 'y');
#       expect(fdja_lk(v, "3.0.1._1") c== '/');
#       expect(fdja_ls(v, "3.0.1._1", NULL) ===f "/c d/");
#     }
#
#     it "accepts /.../i regexes"
#     {
#       v = fdja_dparse_radial(
#         "sequence\n"
#         "  =~ ab /c, d/i\n"
#       );
#
#       ensure(v != NULL);
#
#       ensure(fdja_tod(v) ===f ""
#         "[ sequence, {}, 1, [ "
#           "[ =~, { _0: ab, _1: \"/c, d/i\" }, 2, [] ] "
#         "] ]"
#       );
#
#       expect(fdja_l(v, "3.0.1._1")->type c== 'y');
#       expect(fdja_lk(v, "3.0.1._1") c== '/');
#       expect(fdja_ls(v, "3.0.1._1", NULL) ===f "/c, d/i");
#     }
#   }
# }
#
# describe "fdja_parse_radial_f()"
# {
#   it "reads files"
#   {
#     v = fdja_parse_radial_f("../spec/_test2.rad");
#
#     //puts(fdja_to_json(v));
#
#     expect(v != NULL);
#     //expect(v->source != NULL);
#     expect(v->slen == 0);
#     expect(fdja_lookup_string(v, "0", NULL) ===f "define");
#     expect(fdja_lookup_string(v, "3.0.0", NULL) ===f "mail");
#     expect(fdja_lookup_string(v, "3.0.1.to", NULL) ===f "$(user.email)");
#   }
#
#   it "composes filenames"
#   {
#     v = fdja_parse_radial_f("../spec/_%s2.rad", "test");
#
#     expect(v != NULL);
#     expect(fdja_lookup_string(v, "3.0.1.to", NULL) ===f "$(user.email)");
#   }
#
#   it "returns NULL when it fails to read"
#   {
#     v = fdja_parse_radial_f("../spec/_test3.bad");
#
#     expect(v == NULL);
#   }
# }
#
# describe "fdja_fparse_radial()"
# {
#   it "reads files"
#   {
#     FILE *f = fopen("../spec/_test2.rad", "r");
#     v = fdja_fparse_radial(f, "../spec/_test2.rad");
#
#     //puts(fdja_to_json(v));
#
#     expect(v != NULL);
#     expect(v->slen == 0);
#     expect(fdja_lookup_string(v, "0", NULL) ===f "define");
#     expect(fdja_lookup_string(v, "3.0.0", NULL) ===f "mail");
#     expect(fdja_lookup_string(v, "3.0.1.to", NULL) ===f "$(user.email)");
#
#     fclose(f);
#   }
# }
#
# describe "fdja_parse_r()"
# {
#   it "composes and parses"
#   {
#     v = fdja_parse_r(
#       "sequence\n"
#       "  task %s",
#       "bob",
#       3
#     );
#
#     expect(v != NULL);
#
#     expect(fdja_tod(v) ===f ""
#       "[ sequence, {}, 3, [ "
#         "[ task, { _0: bob }, 4, [] ] "
#       "] ]"
#     );
#   }
# }

