
#
# specifying flor
#
# Sat Dec 26 10:37:45 JST 2015
#

require 'spec_helper'


describe Flor::Radial do

  context 'xxx' do

    it 'flips burgers' do

      expect(
        #Flor::Radial.parse("x [ 1, 2 ]", rewrite: false)
        Flor::Radial.parse("x [ 1, 2 ]")
      ).to eq(
        :x
      )
    end
  end
end

