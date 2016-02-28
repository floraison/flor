
#
# Specifying flor
#
# Thu Nov  5 09:49:17 JST 2015
#

require 'pp'
require 'ostruct'

require 'flor'


RSpec::Matchers.define :eqj do |o|

  match do |actual|

    return actual.strip == JSON.dump(o) if o.is_a?(String)
    JSON.dump(actual) == JSON.dump(o)
  end

  #failure_message do |actual|
  #  "expected #{encoding.downcase.inspect}, got #{$vic_r.to_s.inspect}"
  #end

  #failure_message_for_should do |actual|
  #end
  #failure_message_for_should_not do |actual|
  #end
end

RSpec::Matchers.define :eqd do |o|

  match do |actual|

    return Flor.to_d(actual) == o.strip
  end

  failure_message do |actual|

    "expected #{o.strip}\n" +
    "     got #{Flor.to_d(actual)}"
  end
end

