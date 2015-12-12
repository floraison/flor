
#
# specifying flor
#
# Sat Dec 12 07:05:15 JST 2015
#

require 'spec_helper'


describe Flor::Json do

  context 'numbers' do

    [
      [ '-1', -1 ]
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end
end

