
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Lang do

  compare_flor_to_ruby File.join(File.dirname(__FILE__), 'parser_spec.md')
end

