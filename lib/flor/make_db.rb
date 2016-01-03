
require 'flor'

uri =
  ENV['FLOR_DB_URI'] ||
  case ENV['FLOR_ENV']
    when 'test', 'spec' then 'sqlite://tmp/test.db'
    #else /\Adev(elopment)?\z/ then 'sqlite://tmp/dev.db'
    else 'sqlite://tmp/dev.db'
  end

puts "uri: #{uri.inspect}"

unit = Flor::Unit.new(storage_uri: uri, dispatcher: false)
unit.create_tables

