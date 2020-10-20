# frozen_string_literal: true

require 'io/console'
require 'terminal-table'

module Flor

  class << self

    def to_tt(o)

      h = o.is_a?(Hash) ? o : nil

      if h && h['status'].is_a?(Array) && h['tree'].is_a?(Array)
        node_tt(h)
      elsif h && h['point'].is_a?(String) && h['sm'].is_a?(Integer)
        message_tt(h)
      elsif h
        djan_tt(h)
      else
        pp_tt(o)
      end
    end

    def tt(o)

      puts(to_tt(o))
    end

    protected

    #def columns; `tput cols`.to_i rescue 80; end
    def columns; IO.console.winsize[1] rescue 80; end

    def message_tt(m)

      cols = columns.to_f
      w = (cols * 0.49).to_i

      west =
        "** message **\n\n" +
        Flor.to_d(m.select { |k, _| k != 'cause' }, width: w)
      east =
        "cause:\n\n" +
        Flor.to_d(m['cause'], width: w)

      table = Terminal::Table.new
      table.add_row([ west, east ])
      table.to_s
    end

    def node_tt(n)

      cols = columns.to_f
      w = (cols * 0.49).to_i

      west =
        "** node **\n\n" +
        Flor.to_d(n.select { |k, _| k != 'status' && k != 'tree' }, width: w)
      east =
        "status:\n\n" +
        Flor.to_d(n['status'], width: w)

      table = Terminal::Table.new
      table.add_row([ west, east ])
      table.to_s
    end

    def pp_tt(o)

      table = Terminal::Table.new
      table.add_row([ pp_s(o) ])
      table.to_s
    end

    def djan_tt(o)

      table = Terminal::Table.new
      table.add_row([ Flor.to_d(o) ])
      table.to_s
    end

    def pp_s(o)

      s = StringIO.new
      PP.pp(o, s)

      s.string
    end
  end
end

