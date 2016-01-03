
#
# specifying flor
#
# Sat Jan  2 07:18:18 JST 2016
#

require 'spec_helper'


describe 'Flor a to z' do

  before :each do

    @dom =
      __FILE__[Dir.getwd.length + 1..-9].gsub(/\//, '.')
    @flor =
      Flor::Unit.new(
        storage_uri: 'sqlite://tmp/test.db',
        storage_clean: true)
  end

  after :each do

    @flor.stop
  end

  it 'returns values on their own' do

@flor.storage.connection.loggers << Logger.new($stdout)

    cmp = %{
      2
    }

    exid = @flor.launch("#{@dom}.#{__LINE__}", cmp, {})

    #result = hlp_wait(exid, "terminated", NULL, 3); // exid, point, nid, maxsec
    result = @flor.wait(exid, :terminated)

    expect(result.content['payload']).to eq({ 'ret' => 2 })
    expect(result.payload).to eq({ 'ret' => 2 })
  end

  it 'adds numbers' do

    cmp = %{
      +
        1
        1
    }

    exid = @flor.launch("#{@dom}.#{__LINE__}", cmp, {})

    #result = hlp_wait(exid, "terminated", NULL, 3); // exid, point, nid, maxsec
    result = @flor.wait(exid, :terminated)

    expect(result.content['payload']).to eq({ 'ret' => 2 })
    expect(result.payload).to eq({ 'ret' => 2 })
  end
end

