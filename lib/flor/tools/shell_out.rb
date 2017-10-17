
module Flor::Tools

  class ShellOut

    def initialize(unit)

      @file = File.open('.log.txt', 'wb')
      @file.sync = true

      #@unit.conf['fls_file']
      #@unit.conf['fls_file_mode']
    end

    def tty?

      $stdout.tty?
    end

    def puts(s)

      $stdout.puts(s)
      @file.puts(s)
    end

    def method_missing(*args)
p [ 'MISSING>>>', args ]
    end
  end
end

