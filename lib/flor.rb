
require 'pp'
require 'json'
require 'logger'
require 'thread'
require 'digest'
require 'socket'
require 'forwardable'

require 'munemo'
require 'raabro'
require 'dense'


module Flor

  VERSION = '0.16.0'
  #VERSION = '1.0.0'
end

require 'flor/colours'
require 'flor/djan'

require 'flor/id'
require 'flor/log'
require 'flor/flor'
require 'flor/errors'
require 'flor/parser'
require 'flor/conf'
require 'flor/to_string'

require 'flor/core'
require 'flor/core/node'
require 'flor/core/procedure'
require 'flor/core/executor'
require 'flor/core/texecutor'

Flor.load_procedures('pcore')


#if RUBY_PLATFORM.match(/java/)
#  class Array
#    alias original_collect collect
#    def collect(&block)
#puts caller[0] + " <---"
#      original_collect(&block)
#    end
#  end
#end

