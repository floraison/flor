
module Flor

  class Caller

    def split_cmd(cmd)

      cmd.split(/ +/)
        # FIXME too naive
        # or look at Java's Process Builder documentation, there should be
        # a way to pass cmd strings and not string arrays...
    end

    class ProcessStatus

      attr_reader :process, :exitstatus

      def initialize(process, exitstatus)

        @process = process
        @exitstatus = exitstatus
      end

      def pid; @process.pid; end

    end

    def spawn(conf, data)

      t0 = Time.now

      cmd = conf['cmd']
      acmd = split_cmd(cmd)

      to = Fugit.parse(conf['timeout'] || '14s')
      to = to.is_a?(Fugit::Duration) ? to.to_sec : 14
      to = 0 if to < 0 # no timeout

      builder = java.lang.ProcessBuilder.new(*acmd)
      #pp builder.environment
      process = builder.start
      pid = process.pid

      o = process.outputStream.to_io
      i = process.inputStream.to_io
      f = process.errorStream.to_io

      o.write(data)
      o.close

      ex = Timeout.timeout(to) { process.waitFor }

      status = ProcessStatus.new(process, ex)

      fail SpawnNonZeroExitError.new(conf, { to: to, t0: t0 }, status, i, f) \
        if status.exitstatus != 0

      [ i.read, status ]

    rescue => err

      Process.detach(pid) \
        if pid
      (Process.kill(9, pid) rescue nil) \
        unless Flor.no?(conf['on_error_kill'])

      raise err if err.is_a?(SpawnError)
      raise WrappedSpawnError.new(conf, { to: to, t0: t0, pid: pid }, err)

    ensure

      [ i, o, f ].each { |x| x.close rescue nil }

    end
  end
end

