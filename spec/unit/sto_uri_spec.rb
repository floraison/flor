
#
# specifying flor
#
# Sun Nov 22 13:48:51 JST 2020
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    DB = Sequel.connect(
      RUBY_PLATFORM.match(/java/) ?
        'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db')
  end

  it 'lets one use a string pointing to a constant "DB"' do

    expect {
      unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: 'DB')
    }.not_to raise_error
  end
end

