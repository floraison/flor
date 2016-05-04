
#
# Specifying flor
#
# Thu Nov  5 09:49:17 JST 2015
#

require 'pp'
require 'ostruct'

require 'flor'
require 'flor/unit'


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

    def compare_flon_to_ruby(fpath)

      lines = File.readlines(fpath)

      contexts = []
      current = nil
      con = nil

      lin = -1
      mod = :out
      flon = []
      rub = []
      pnd = false

      lines.each_with_index do |line, i|

        if mod == :out && m = line.match(/^## +(.+)$/)

          contexts << [ con, current ] if con
          current = []
          con = m[1]

        elsif line.match(/pending/)

          pnd = true

        elsif mod == :out && line.match(/\A```ruby\b/)

          mod = :ruby

        elsif mod == :out && line.match(/\A```flon\b/)

          lin = i + 1
          mod = :flon

        elsif line == "```\n"

          if mod == :ruby

            current << [ lin, flon.join, rub.join, pnd ]

            lin = -1
            rub = []
            flon = []
            pnd = false
          end
          mod = :out

        elsif mod != :out

          (mod == :ruby ? rub : flon) << line
        end
      end

      contexts << [ con, current ]

      contexts.each do |con, li_ra_ru_pn_s|

        context(con) do

          li_ra_ru_pn_s.each do |lin, flon, rub, pnd|

            ra = flon.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
            ra = "#{ra[0, 60]}..." if ra.length > 60
            title = "parses li#{lin} `#{ra}`"

            ru = Kernel.eval(rub)

            if pnd
              pending(title)
            else
              it(title) { expect(Flor::Lang.parse(flon)).to eqt(ru) }
            end
          end
        end
      end
    end
  end
end

