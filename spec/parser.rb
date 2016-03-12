
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  lines = File.readlines(File.join(File.dirname(__FILE__), 'parser.md'))

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
        ra = "#{tra[0, 60]}..." if ra.length > 60
        title = "parses li#{lin} `#{ra}`"

        ru = Kernel.eval(rub)

        it(title) { expect(Flor::Rad.parse(ra)).to eq(ru) }
      end
    end
  end
end

