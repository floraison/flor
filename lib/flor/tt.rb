# frozen_string_literal: true

require 'io/console'
require 'terminal-table'

module Flor

  class << self

    def to_tt(o, opts={})

      h = o.is_a?(Hash) ? o : nil

      if h && h['status'].is_a?(Array) && h['nid'].is_a?(String)
        node_tt(h, opts)
      elsif h && h['point'].is_a?(String) && h['sm'].is_a?(Integer)
        message_tt(h, opts)
      elsif h
        djan_tt(h, opts)
      else
        pp_tt(o, opts)
      end
    end

    def tt(o, opts={})

      puts(to_tt(o, opts))
    end

    protected

    #def columns; `tput cols`.to_i rescue 80; end
    def columns; IO.console.winsize[1] rescue 80; end

    def make_tt_table(opts, &block)

      c = Flor.colours(opts)

      table = Terminal::Table.new
      table.style.border_x = opts[:border_x] || c.dg('-')
      table.style.border_i = opts[:border_i] || c.dg('.')
      table.style.border_y = opts[:border_y] || c.dg('|')

      block.call(table) if block

      table
    end

    def message_tt(m, opts)

      cols = columns.to_f
      w = (cols * 0.49).to_i

      west =
        "** message **\n\n" +
        Flor.to_d(m.select { |k, _| k != 'cause' }, width: w)
      east =
        "cause:\n\n" +
        Flor.to_d(m['cause'], width: w)

      make_tt_table(opts) { |t| t.add_row([ west, east ]) }.to_s
    end

    def node_tt(n, opts)

      cols = columns.to_f
      w = (cols * 0.49).to_i

      west =
        "** node **\n\n" +
        Flor.to_d(n.select { |k, _| k != 'status' && k != 'tree' }, width: w)
      east =
        "status:\n\n" +
        Flor.to_d(n['status'], width: w)

      make_tt_table(opts) { |t| t.add_row([ west, east ]) }.to_s
    end

    def pp_tt(o, opts)

      make_tt_table(opts) { |t| t.add_row([ pp_s(o, opts) ]) }.to_s
    end

    def djan_tt(o, opts)

      make_tt_table(opts) { |t| t.add_row([ Flor.to_d(o) ]) }.to_s
    end

    def pp_s(o, opts)

      s = StringIO.new
      PP.pp(o, s)

      s.string
    end
  end
end

