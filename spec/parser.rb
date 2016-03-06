
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  context 'basic' do

    [

      [ %{
          sequence
        },
        [ 'sequence', [], 2 ],
        __LINE__ ],

    ].each do |ra, tr, li|

      title = "parses li#{li} `#{ra.strip}`"

      it(title) do

        expect(Flor::Rad.parse(ra)).to eq(tr)
      end
    end
  end
end

