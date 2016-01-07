
#
# specifying flor
#
# Wed Dec 30 07:41:13 JST 2015
#

require 'spec_helper'


describe 'Flor.launch' do

  before :each do

    @dom =
      __FILE__[Dir.getwd.length + 1..-9].gsub(/\//, '.')
    @flor =
      Flor::Unit.new(
        storage_uri: 'sqlite://tmp/test.db',
        storage_clean: true,
        dispatcher: false)
  end

  it 'launches' do

    t = %{
      +
        1
        2
    }

    exid = @flor.launch("#{@dom}.#{__LINE__}", t, {})

    expect(exid).to match(/\Aspec\.unit\.launch\.\d+-u0-#{Time.now.year}/)

    msg = @flor.storage.connection[:flor_items].order(:id).last
    #p msg

    expect(msg[:type]).to eq('message')
    expect(msg[:subtype]).to eq('dispatcher')
    expect(msg[:domain]).to eq(exid.split('-').first)
    expect(msg[:exid]).to eq(exid)
    expect(msg[:status]).to eq('created')

    j = JSON.parse(msg[:content])
    expect(j['point']).to eq('execute')
    expect(j['payload']).to eq({})

    expect(j['tree']).to eqj(
      [ '+', {}, 2, [
        [ 'val', { '_0' => 1 }, 3, [] ],
        [ 'val', { '_0' => 2 }, 4, [] ]
      ] ])
  end
end

