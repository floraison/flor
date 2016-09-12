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
module Flor::Tools; end

module Flor::Tools::Env

  def self.make(path, envname=nil, opts={})

    if envname.is_a?(Hash)
      opts = envname
      envname = nil
    end

    opts[:env] = envname || 'production'
    opts[:sto_uri] ||= 'sqlite://tmp/dev.db'
    opts[:gitkeep] = true unless opts.has_key?(:gitkeep)

    mkdir(path, envname) if envname

    mk_etc(path, envname, opts)
    mk_lib(path, envname, opts)
    mk_usr(path, envname, opts)
  end

  # protected, somehow

  def self.mk_etc(*ps, opts)

    mkdir(*ps, 'etc')
    mkdir(*ps, 'etc', 'variables')
    touch(*ps, 'etc', 'variables', '.gitkeep') if opts[:gitkeep]

    write(*ps, 'etc', 'conf.json') do
      "env: #{opts[:env]}\n" +
      "sto_uri: #{opts[:sto_uri].inspect}"
    end
  end

  def self.mk_lib(*ps, opts)

    mkdir(*ps, 'lib')
    mkdir(*ps, 'lib', 'flows')
    touch(*ps, 'lib', 'flows', '.gitkeep') if opts[:gitkeep]
    mkdir(*ps, 'lib', 'taskers')
    touch(*ps, 'lib', 'taskers', '.gitkeep') if opts[:gitkeep]
  end

  def self.mk_usr(*ps, opts)

    mkdir(*ps, 'usr')

    if opts[:acme] == false
      touch(*ps, 'usr', '.gitkeep') if opts[:gitkeep]
    else
      mkdir(*ps, 'usr', 'com.acme')
      mk_etc(*ps, 'usr', 'com.acme', opts)
      mk_lib(*ps, 'usr', 'com.acme', opts)
    end
  end

  def self.mkdir(*ps); FileUtils.mkdir(File.join(*ps.compact)); end
  def self.touch(*ps); FileUtils.touch(File.join(*ps.compact)); end

  def self.write(*ps, &block)

    File.open(File.join(*ps.compact), 'wb') { |f| f.write(block.call) }
  end
end

