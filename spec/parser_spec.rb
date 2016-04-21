
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Lang do

  compare_flon_to_ruby File.join(File.dirname(__FILE__), 'parser.md')
end

