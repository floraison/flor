
require 'flor'
require 'flor/unit'

module Flor::Tools
  module Repl

    def self.start(env)

      unit = Flor::Unit.new("envs/#{env}/etc/conf.json")

      #pp unit.conf
      unit.conf[:unit] = 'repl'

      #unit.hooker.add('journal', Flor::Journal)
      if unit.conf['sto_uri'].match(/memory/)
        unit.storage.delete_tables
        unit.storage.migrate
      end
      unit.start

      loop do

        $stdout.print("flor> ")
        line = ($stdin.readline rescue false); break unless line
        p line
      end

      $stdout.puts
    end

    protected # somehow

    def cmd_launch
    end
    def cmd_help
    end
  end
end

