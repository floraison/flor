
#
# specifying flor
#
# Mon Aug 13 11:47:02 CEST 2018  Neyruz
#

require 'spec_helper'


describe 'Flor procedures' do

  describe 'flatten' do

    {

      "flatten [ 1 2 3 ] null" => [ 1, 2, 3 ],
      "flatten [ 1 [ 2 3 ] 4 ] null" => [ 1, 2, 3, 4 ],
      "flatten [ 1 [ 2 3 ] 4 ] 1" => [ 1, 2, 3, 4 ],
      "flatten [ 1 [ 2 [ 3 ] ] 4 ] 1" => [ 1, 2, [ 3 ], 4 ],

      "[ 1, [ 2, [ 3 ] ], 4 ] | flatten _" => [ 1, 2, 3, 4 ],
      "[ 1, [ 2, [ 3 ] ], 4 ] | flatten 1" => [ 1, 2, [ 3 ], 4 ],

    }.test_each(self)

    [

      'flatten _'

    ].test_each_fail(self, 'missing collection')
  end
end

