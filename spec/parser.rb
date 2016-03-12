
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  lines = File.readlines(File.join(File.dirname(__FILE__), 'parser.md'))

  mod = :out
  rad = []
  rub = []

  lines.each_with_index do |line, i|

    if mod == :out && line == "```ruby\n"

      mod = :ruby

    elsif mod == :out && line == "```radial\n"

      mod = :radial

    elsif line == "```\n"

      if mod == :ruby

        rad = rad.join
        ra = rad.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
        ra = "#{tra[0, 60]}..." if ra.length > 60
        title = "parses li#{i} `#{ra}`"

        ru = Kernel.eval(rub.join)

        it(title) { expect(Flor::Rad.parse(ra)).to eq(ru) }

        rub = []
        rad = []
      end
      mod = :out
    elsif mod != :out
      (mod == :ruby ? rub : rad) << line
    end
  end
end

