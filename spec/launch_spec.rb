
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
      Flor::Unit.new(storage_uri: 'sqlite://tmp/test.db', dispatcher: false)
  end

  it 'launches' do

    t = %{
      +
        1
        2
    }

    exid = @flor.launch("#{@dom}.#{__LINE__}", t, {})
  end
end

