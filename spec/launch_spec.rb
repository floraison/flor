
#
# specifying flor
#
# Wed Dec 30 07:41:13 JST 2015
#

require 'spec_helper'


describe 'Flor.launch' do

  it 'launches' do

    t = Flor::Radial.parse(%{
      +
        1
        2
    })

    exid = Flor.launch('spec.x', t, {})
  end
end

