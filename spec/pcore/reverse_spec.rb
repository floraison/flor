
#
# specifying flor
#
# Thu Jun 15 15:56:45 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  describe 'reverse' do

    {

      %q{ reverse [ 1, 2, 3 ] } => [ 3, 2, 1 ],
      %q{ [ 1, 2, 3 ]; reverse _ } => [ 3, 2, 1 ],
      %q{ reverse 'melimelo' } => 'melimelo'.reverse,
      %q{ (reverse 'onegin' tag: 'a') } => 'onegin'.reverse,

    }.test_each(self)

    [

      %q{ reverse _ },

    ].test_each_fail(self, 'found no argument that could be reversed', lin: 1)
  end
end

