#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'pp'
require 'json'
require 'logger'
require 'thread'
require 'digest'

require 'munemo'
require 'raabro'


module Flor

  VERSION = '0.9.2'
end

require 'flor/colours'

require 'flor/log'
require 'flor/flor'
require 'flor/dollar'
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

