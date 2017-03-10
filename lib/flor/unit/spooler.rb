
module Flor

  class Spooler

    # NB: logger configuration entries start with "spo_"

    def initialize(unit)

      @unit = unit

      @dir = @unit.conf['spo_dir'] || 'var/spool'
      @dir = File.join(@unit.conf['root'], @dir) if @dir
      @dir = nil unless File.directory?(@dir)
    end

    def shutdown
    end

    def spool

      return unless @dir
    end
  end
end

