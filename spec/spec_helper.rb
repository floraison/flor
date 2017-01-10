
#
# Specifying flor
#
# Thu Nov  5 09:49:17 JST 2015
#

require 'pp'
require 'ostruct'

require 'flor'
require 'flor/unit'


def jruby?

  !! RUBY_PLATFORM.match(/java/)
end

def wait_until(timeout=14, frequency=0.1, &block)

  start = Time.now

  loop do

    sleep(frequency)

    return if block.call == true
    break if Time.now - start > timeout
  end

  fail "timeout after #{timeout}s"
end

def to_s(o)

  if o.is_a?(Array)

    o.collect { |e| to_s(e) }.join("\n")

  elsif o['point'].is_a?(String)

    s = StringIO.new
    s << "(msg #{o['nid']} #{o['point']}"
    %w[ from flavour ].each { |k|
      s << ' ' << k << ':' << o[k].to_s if o.has_key?(k) }
    s << ")"

    s.string

  else

    o.inspect
  end
end


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

RSpec::Matchers.define :comprise do |o|

  match do |actual|

    return false unless actual.is_a?(Array)

    a = actual
    loop do
      return false if a.length < o.length
      return true if a[0, o.length] == o
      a = a[1..-1]
    end

    false
  end

  failure_message do |actual|

    "expected\n  #{actual.inspect}\nto comprise\n  #{o.inspect}"
  end
end


class RSpec::Core::ExampleGroup

  class << self

    def compare_flor_to_ruby(fpath)

      lines = File.readlines(fpath)

      contexts = []
      current = nil
      con = nil

      lin = -1
      mod = :out
      flor = []
      rub = []
      sta = :active

      lines.each_with_index do |line, i|

        if mod == :out && m = line.match(/^## +(.+)$/)

          contexts << [ con, current ] if con
          current = []
          con = m[1]

        elsif line.match(/pending/)

          sta = :pending

        elsif line.match(/hidden/)

          sta = :hidden

        elsif mod == :out && line.match(/\A```ruby\b/)

          mod = :ruby

        elsif mod == :out && line.match(/\A```flor\b/)

          lin = i + 1
          mod = :flor

        elsif line == "```\n"

          if mod == :ruby

            current << [ lin, flor.join, rub.join, sta ]

            lin = -1
            rub = []
            flor = []
            sta = :active
          end
          mod = :out

        elsif mod != :out

          (mod == :ruby ? rub : flor) << line
        end
      end

      contexts << [ con, current ]

      contexts.each do |con, li_ra_ru_pn_s|

        context(con) do

          li_ra_ru_pn_s.each do |lin, flor, rub, sta|

            ra = flor.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
            ra = "#{ra[0, 60]}..." if ra.length > 60
            title = "parses li#{lin} `#{ra}`"

            ru = Kernel.eval(rub)

            if sta == :hidden
              # do nothing
            elsif sta == :pending
              pending(title)
            else
              it(title) { expect(Flor::Lang.parse(flor)).to eqt(ru) }
            end
          end
        end
      end
    end
  end
end

