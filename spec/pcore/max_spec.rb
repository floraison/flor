
#
# specifying flor
#
# Mon Dec 24 16:41:00 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  describe 'max' do

    {

      %q{ max [ 1, 2, 3 ] } => 3,
      %q{ [ 1, 2, 3 ]; max _ } => 3,
      %q{ max [ 1, 2, 3 ] tag: 'x' } => 3,
      %q{ [ 1, 2, 3 ]; max tag: 'y' } => 3,

    }.test_each(self)

    [

      %q{ max [ false 1 ] },

    ].test_each_fail(self, /comparison of (Fixnum|Integer) with false failed/)

    context 'loose:/lax: true' do

      {

        %q{ max [ 1 3 1 ] lax: true } => 3,
        %q{ max lax: true, [ 1 3 1 ] } => 3,
        %q{ max [ 1 3 'two' ] lax: true } => 3,

      }.test_each(self)
    end
  end

  describe 'min' do

    {

      %q{ min [ 1, 2, 3, -1 ] } => -1,
      %q{ [ 1, 2, 3, -1 ]; min _ } => -1,
      %q{ min [ 1, 2, 3, -1 ] tag: 'x' } => -1,
      %q{ [ 1, 2, 3, -2 ]; min tag: 'y' } => -2,

    }.test_each(self)

    context 'loose:/lax: true' do

      {

        %q{ min [ 1 3 1 ] lax: true } => 1,
        %q{ min lax: true, [ 1 3 1 ] } => 1,
        %q{ min [ 1 3 'two' ] lax: true } => 'two',

      }.test_each(self)
    end
  end
end

