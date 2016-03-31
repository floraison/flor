
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  compare_rad_to_ruby File.join(File.dirname(__FILE__), 'parser.md')
end

