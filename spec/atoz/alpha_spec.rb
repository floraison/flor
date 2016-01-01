
#
# specifying flor
#
# Sat Jan  2 07:18:18 JST 2016
#

require 'spec_helper'


describe 'Flor a to z' do

  before :each do

    clean_flor
    start_flor
  end

  after :each do

    stop_flor
  end

  it 'adds numbers' do

    cmp = %{
      +
        1
        1
    }

    exid = Flor.launch(cmp, {})

    #result = hlp_wait(exid, "terminated", NULL, 3); // exid, point, nid, maxsec
    result = Flor.wait(exid, :terminated)

    expect(result.content['payload']).to eq({ 'ret' => 2 })
    expect(result.payload).to eq({ 'ret' => 2 })
  end
end

