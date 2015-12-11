
#
# specifying flor
#
# Sat Dec 12 07:05:15 JST 2015
#

require 'spec_helper'


describe Flor::Djan do

  context 'json' do

    context 'numbers' do

      [
        [ '-1', -1 ]
      ].each do |a|

        it "parses #{a[0].inspect}" do

          expect(Flor::Djan.parse(a[0])).to eq(a[1])
        end
      end
    end
  end
end

