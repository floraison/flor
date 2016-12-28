
#
# specifying flor
#
# Wed Dec 28 16:57:36 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'break' do

    it 'breaks an "until" from outside'
    it 'breaks a "cursor" from outside'
  end

  describe 'continue' do

    it 'continues an "until" from outside'
    it 'continues a "cursor" from outside'
  end
end

