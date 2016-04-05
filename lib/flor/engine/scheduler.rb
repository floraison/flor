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

require 'logger'


module Flor

  class Scheduler

    def initialize(db, opts={})

      @db = db
      @frequency = opts[:frequency] || 0.3
      @logger = opts[:logger] || Logger.new($stdout)

      @thread = nil

      start
    end

    def start

      @thread =
        Thread.new do
          loop do
            begin
              sleep(@frequency)
              log(:info, "woke up at #{Flor.tstamp}")
            rescue => e
              log(:error, 'ouch', e)
            end
          end
        end

      self
    end

    def join

      @thread.join
    end

    protected

    def log(level, message, err=nil)

      message = "#{message} #{err.inspect}" if err

      @logger.send(level, message)
    end
  end
end

