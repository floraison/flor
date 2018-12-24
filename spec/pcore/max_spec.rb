
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
  end

  describe 'min' do

    {

      %q{ min [ 1, 2, 3, -1 ] } => -1,
      %q{ [ 1, 2, 3, -1 ]; min _ } => -1,
      %q{ min [ 1, 2, 3, -1 ] tag: 'x' } => -1,
      %q{ [ 1, 2, 3, -2 ]; min tag: 'y' } => -2,

    }.test_each(self)
  end
end

