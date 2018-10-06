
#
# specifying flor
#
# Fri Oct  5 13:02:33 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  describe 'split' do

    {

      'split "ab cd ef"' => %w[ ab cd ef ],
      'split "ab|cd|ef" "|"' => %w[ ab cd ef ],
      'split "ab|cd|ef" r/\|/' => %w[ ab cd ef ],
      'split "ab|cd|ef" (/\|/)' => %w[ ab cd ef ],
      '"ab|cd|ef"; split "|"' => %w[ | ],
      '"ab,cd,ef"; split r/,/' => %w[ ab cd ef ],
      '"ab cd ef"; split tag: "x"' => %w[ ab cd ef ],

    }.test_each(self)

    [

      'split 1',
      'split r/,/',
      'r/,/; split _',
      '123; split _',

    ].test_each_fail(self, 'found no string to split')
  end
end

