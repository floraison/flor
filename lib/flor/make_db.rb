
require 'flor'

uri =
  ENV['FLOR_DB_URI'] ||
  case ENV['FLOR_ENV']
    when 'test', 'spec' then 'sqlite://tmp/test.db'
    #else /\Adev(elopment)?\z/ then 'sqlite://tmp/dev.db'
    else 'sqlite://tmp/dev.db'
  end

puts "uri: #{uri.inspect}"

sto = Flor::Storage.new(uri, dispatcher: false)
sto.create_tables

