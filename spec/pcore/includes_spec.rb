
#
# specifying flor
#
# Sat Jan 20 08:19:37 JST 2018  Between SIN and HIJ
#

require 'spec_helper'


describe 'Flor procedures' do

  describe 'includes?' do

    {

      %q{ includes? [ 0 ] 0 } => true,
      %q{ includes? [ [ 0 ] ] [ 0 ] } => true,
      %q{ includes? { a: 'A' } 'a' } => true,
      %q{ includes? 1 [ 1 ] } => true,
      %q{ includes? 'b' { a: 'A', 'b': 'B' } } => true,

      %q{ includes? [] 0 } => false,
      %q{ includes? [] [] } => false,
      %q{ includes? { a: 'A' } 'b' } => false,
      %q{ includes? 1 [ 2 ] } => false,
      %q{ includes? 'c' { a: 'A', 'b': 'B' } } => false,

      %q{ []; includes? 1 } => false,
      %q{ [ 0 1 2 ]; includes? 1 } => true,

    }.test_each(self)

    [

      'includes? []',

    ].test_each_fail(self, 'missing element')

    [

      'includes? 1',

    ].test_each_fail(self, 'missing collection')
  end
end

