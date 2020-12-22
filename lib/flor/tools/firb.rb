# frozen_string_literal: true

require 'irb'

#require 'sequel'
require 'flor'
require 'flor/unit'


p [ RUBY_VERSION, RUBY_PLATFORM ]

puts

ENV.each do |k, v|
  next unless k.match?(/RUBY|GEM/)
  puts "* #{k}: #{v}"
end

ARGV.each do |arg|
  if arg.match(/:/)
    DB = Sequel.connect(arg)
    p DB
  end
end

#MODELS = [ :executions, :timers, :traces, :traps, :pointers, :messages ]
if defined?(DB)
  Flor::Message.dataset = DB[:flor_messages]
end

ARGV.clear
IRB.start

