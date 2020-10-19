# frozen_string_literal: true

module Flor

  class << self

    # See Scheduler#dump for the details
    #
    def dump(db_or_unit_or_uri, io=nil, opts=nil, &block)

      derive_unit(db_or_unit_or_uri)
        .dump(io, opts, &block)
    end

    # See Scheduler#load for the details
    #
    def load(db_or_unit_or_uri, string_or_io, opts={}, &block)

      derive_unit(db_or_unit_or_uri)
        .load(string_or_io, opts, &block)
    end

    protected

    def derive_unit(db_or_unit_or_uri)

      case o = db_or_unit_or_uri
      when Flor::Unit then o
      when Sequel::Database then Flor::Unit.new(sto_db: o)
      when String then Flor::Unit.new(sto_uri: o)
      else fail ArgumentError.new("cannot derive flor Unit out of #{o.inspect}")
      end
    end
  end
end

