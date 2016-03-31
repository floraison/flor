
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

  o0 = o
  o = Flor.to_d(o) unless o.is_a?(String)
  o = o.strip

  match do |actual|

    return Flor.to_d(actual) == o
  end

  failure_message do |actual|

    "expected #{o}\n" +
    "     got #{Flor.to_d(actual)}"
  end
end

RSpec::Matchers.define :eqt do |o|

  match do |actual|

    actual == o
  end

  failure_message do |actual|

    so = StringIO.new
      .tap { |io| PP.pp(o, io, 67) }.string.gsub(/^/, ' ' * 2)
    sactual = StringIO.new
      .tap { |io| PP.pp(actual, io, 67) }.string.gsub(/^/, ' ' * 2)

    "expected:\n" + so + "\ngot:\n" + sactual
  end
end


class RSpec::Core::ExampleGroup

  class << self

    def compare_rad_to_ruby(fpath)

      lines = File.readlines(fpath)

      contexts = []
      current = nil
      con = nil

      lin = -1
      mod = :out
      rad = []
      rub = []

      lines.each_with_index do |line, i|

        if mod == :out && m = line.match(/^## +(.+)$/)

          contexts << [ con, current ] if con
          current = []
          con = m[1]

        elsif mod == :out && line == "```ruby\n"

          mod = :ruby

        elsif mod == :out && line == "```radial\n"

          lin = i + 1
          mod = :radial

        elsif line == "```\n"

          if mod == :ruby
            current << [ lin, rad.join, rub.join ]

            lin = -1
            rub = []
            rad = []
          end
          mod = :out

        elsif mod != :out

          (mod == :ruby ? rub : rad) << line
        end
      end

      contexts << [ con, current ]

      contexts.each do |con, li_ra_ru_s|

        context(con) do

          li_ra_ru_s.each do |lin, rad, rub|

            ra = rad.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
            ra = "#{ra[0, 60]}..." if ra.length > 60
            title = "parses li#{lin} `#{ra}`"

            ru = Kernel.eval(rub)

            it(title) { expect(Flor::Rad.parse(rad)).to eqt(ru) }
          end
        end
      end
    end
  end
end

