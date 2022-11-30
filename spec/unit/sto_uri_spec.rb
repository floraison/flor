
#
# specifying flor
#
# Sun Nov 22 13:48:51 JST 2020
#

require 'spec_helper'


module Sto; module Uri
  SPEC =
    Sequel.connect(
      RUBY_PLATFORM.match(/java/) ? 'jdbc:sqlite://tmp/test.db' :
      'sqlite://tmp/test.db')
end; end


describe 'Flor unit' do

  it 'lets one use a string pointing to a constant "DBX"' do

    DBX =
      Sequel.connect(
        RUBY_PLATFORM.match(/java/) ? 'jdbc:sqlite://tmp/test.db' :
        'sqlite://tmp/test.db')

    expect {
      Flor::Unit.new(loader: Flor::HashLoader, sto_uri: 'DBX')
    }.not_to raise_error
  end

  it 'lets one use a string pointing to a constant "Sto::Uri::SPEC"' do

    expect {
      Flor::Unit.new(loader: Flor::HashLoader, sto_uri: 'Sto::Uri::SPEC')
    }.not_to raise_error
  end
end

