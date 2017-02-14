#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
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


module Flor

  module Conf

    # * uni_ unit prefix (or no prefix like for :env)
    # * sch_ scheduler prefix
    # * sto_ storage prefix
    # * exe_ executor prefix
    # * log_ logger prefix
    #
    #
    # * :uni_name
    #   The name for the unit (Scheduler+Storage) pair.
    #   The name must match the following regex: `/\A[a-zA-Z0-9_]+\z/`
    #   Can also be set via the FLOR_UNIT environment variable.
    #
    # * :sch_heart_rate
    #   Defaults to 0.3s, every 0.3s the scheduler checks its @wake_up and
    #   @next_time fields to determine if it has to run (no db query)
    #   @wake_up is set to true when there are incoming messages give to
    #   this unit, @next_time simply holds the timestamp for the next timer
    #   that has to trigger
    #
    # * :sch_reload_after
    #   reload/resync with db after how much time? (defaults to 60 (seconds))
    #   minimizes communication with db in idle periods
    #
    # * :sch_max_executors
    #   How many executor thread at most? (defaults to 7, 1 is OK in certain
    #   environments)
    #
    # * :exe_max_messages
    #   How many messages will an executor run in a single session
    #   (before quitting and passing the hand) Defaults to 77
    #   An executor will not run indefinitely as long as they are messages.
    #   The goal is to prevent an execution from monopolizing an executor.
    #
    # And finally:
    #
    # * :flor_debug or :debug
    #
    #   Usually set via the FLOR_DEBUG environment variable.
    #   * `msg` displays the flor messages in a summary, colored format
    #   * `err` displays errors with details, when and if they happen
    #   * `src` displays the source before it gets parsed and launched
    #   * `tree` displays the syntax tree as parsed from the source, right
    #     before launch
    #   * `run` shows info about each [run](doc/glossary.md#run) that just ended
    #   * `sto` displays debug information about the
    #           [storage](doc/glossary.md#storage), it's mostly SQL statements
    #
    #   * `stdout` states that the debug messages must go to STDOUT
    #   * `stderr` states that the debug messages must go to STDERR
    #
    #   For example `debug: 'msg,stdout'`

    def self.read(s)

      h = {}
      h.merge!(Flor::ConfExecutor.interpret(s))
      h.merge!(interpret_flor_debug(h['flor_debug'] || h['debug']))

      h
    end

    def self.read_env

      h = {}
      h.merge!(interpret_env)
      h.merge!(interpret_flor_debug(ENV['FLOR_DEBUG']))

      h
    end

    def self.get_class(conf, key)

      if v = conf[key]
        Kernel.const_get(v)
      else
        nil
      end
    end

    protected # somehow

    LOG_DBG_KEYS = %w[ dbg msg err src tree tree_rw run ]
    LOG_ALL_KEYS = %w[ all log sto ] + LOG_DBG_KEYS

    def self.interpret_flor_debug(v)

      a = v || ''
      a = a.split(',') if a.is_a?(String)
      a = a.collect(&:strip)

      h =
        a.inject({}) { |h, kv|
          k, v = kv.split(':')
          k = 'sto' if k == 'db'
          k = "log_#{k}" if LOG_ALL_KEYS.include?(k)
          h[k] = v ? JSON.parse(v) : true
          h
        }
      LOG_ALL_KEYS.each { |k| h["log_#{k}"] = 1 } if h['log_all']
      LOG_DBG_KEYS.each { |k| h["log_#{k}"] = 1 } if h['log_dbg']

      h['log_colours'] = true \
        if a.include?('colours') || a.include?('colors')
          # LOG_DEBUG=colours forces colors

      if a.include?('stdout')
        h['log_out'] = 'stdout'
      elsif a.include?('stderr')
        h['log_out'] = 'stderr'
      end

      h
    end

    def self.interpret_env

      h = {}
      u = ENV['FLOR_UNIT']
      h['unit'] = u if u

      h
    end
  end
end

