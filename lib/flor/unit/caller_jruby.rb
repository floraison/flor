
module Flor

  class Caller

    def split_cmd(cmd)

      #cmd.split(/ +/)
        # too naive

#Raabro.pp(Flor::Caller::CmdParser.parse(cmd, debug: 3), colours: true)
      Flor::Caller::CmdParser.parse(cmd)
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

    module CmdParser include Raabro

      # parsing

      def separator(i); rex(nil, i, /[ 	]+/); end

      def dqstring(i)
        rex(:string, i, %r{
          "(
            \\["\\\/bfnrt] |
            \\u[0-9a-fA-F]{4} |
            [^"\\\b\f\n\r\t]
          )*"
        }x)
      end

      def sqstring(i)
        rex(:string, i, %r{
          '(
            \\['\\\/bfnrt] |
            \\u[0-9a-fA-F]{4} |
            [^'\\\b\f\n\r\t]
          )*'
        }x)
      end

      def word(i); rex(:word, i, /[^ 	"']+/); end

      def item(i); alt(nil, i, :word, :sqstring, :dqstring); end

      def cmd(i); jseq(:cmd, i, :item, :separator); end

      # rewriting

      def rewrite_word(t); t.string; end

      def rewrite_string(t)
        s = t.string[1..-2]
        s == 'sleep' ? t.string : s # ah, the awful thing :-(
      end
        #
        # because of `ruby -e "sleep"` :-( is there another way?

      def rewrite_cmd(t)

#Raabro.pp(t, colours: true)
        t.subgather(nil).collect { |tt| rewrite(tt) }
      end
    end
  end
end

