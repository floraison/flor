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

require 'fileutils'


module Flor; end

module Flor::Tools

  def self.mkenv(path, envname=nil, opts={})

    if envname.is_a?(Hash)
      opts = envname
      envname = nil
    end

    opts[:gitkeep] = true unless opts.has_key?(:gitkeep)

    mkdir(path, envname, 'etc')
    mkdir(path, envname, 'etc', 'variables')
    touch(path, envname, 'etc', 'variables', '.gitkeep') if opts[:gitkeep]

    write(path, envname, 'etc', 'conf.json') do
      "env: #{opts[:env] || 'production'}\n" +
      "sto_uri: 'sqlite://tmp/dev.db'"
    end

    mkdir(path, envname, 'lib')
    mkdir(path, envname, 'lib', 'flows')
    touch(path, envname, 'lib', 'flows', '.gitkeep') if opts[:gitkeep]
    mkdir(path, envname, 'lib', 'taskers')
    touch(path, envname, 'lib', 'taskers', '.gitkeep') if opts[:gitkeep]

    mkdir(path, envname, 'usr')
    touch(path, envname, 'usr', '.gitkeep') if opts[:gitkeep]
  end

  def self.mkdir(*ps); FileUtils.mkdir(File.join(*ps.compact)); end
  def self.touch(*ps); FileUtils.touch(File.join(*ps.compact)); end

  def self.write(*ps, &block)

    File.open(File.join(*ps.compact), 'wb') { |f| f.write(block.call) }
  end
end

