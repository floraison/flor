#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
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

require 'munemo'
require 'raabro'


module Flor

  VERSION = '0.4.0'
end

require 'flor/flor'
require 'flor/dollar'
require 'flor/errors'
require 'flor/parser'
require 'flor/conf'

require 'flor/executor/node'
require 'flor/executor/procedure'
require 'flor/executor/core'
require 'flor/executor/logger'
require 'flor/executor/transient'


#
# load callables

module Flor

  def self.load_procedures(dir)

    dirpath =
      if dir.match(/\A[.\/]/)
        File.join(dir, '*.rb')
      else
        File.join(File.dirname(__FILE__), 'flor', dir, '*.rb')
      end

    Dir[dirpath].each { |path| require(path) }
  end
end

Flor.load_procedures('pcore')

#Flor.load_procedures('pstan')
  # to be loaded only if using more than the transient executor

