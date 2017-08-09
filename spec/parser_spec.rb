
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Parser do

  compare_flor_to_ruby File.join(File.dirname(__FILE__), 'parser_spec.md')

  context 'when parsing fails' do

    it 'returns the error location'# do
#
#      flor =
#        %q{
#          sequence
#            nada
#          .
#        }
#
#      x = Flor::Lang.parse(flor, 'x.flor')
#    end
  end
end

