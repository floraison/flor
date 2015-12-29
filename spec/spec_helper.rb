
#
# Specifying flor
#
# Thu Nov  5 09:49:17 JST 2015
#

require 'pp'
require 'ostruct'

require 'sequel'
module Flor; DB = Sequel.connect('sqlite:tmp/test.db'); end

require 'flor'

