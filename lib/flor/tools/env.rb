
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
    mk_var(path, envname, opts)
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

  def self.mk_var(*ps, opts)

    mkdir(*ps, 'var')
    mkdir(*ps, 'var', 'log')
    touch(*ps, 'var', 'log', '.gitkeep') if opts[:gitkeep]
  end

  def self.mkdir(*ps); FileUtils.mkdir(File.join(*ps.compact)); end
  def self.touch(*ps); FileUtils.touch(File.join(*ps.compact)); end

  def self.write(*ps, &block)

    File.open(File.join(*ps.compact), 'wb') { |f| f.write(block.call) }
  end
end

