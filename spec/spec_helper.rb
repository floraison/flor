
#
# Specifying flor
#
# Thu Nov  5 09:49:17 JST 2015
#

require 'pp'
require 'ostruct'

require 'jruby/synchronized' if RUBY_PLATFORM.match(/java/)

require 'flor'
require 'flor/unit'
require 'fileutils'

F = Flor
  # quicker access to Flor.to_s and co


module Helpers

  def jruby?

    !! RUBY_PLATFORM.match(/java/)
  end

  def wait_until(timeout=14, frequency=0.1, &block)

    start = Time.now

    loop do

      sleep(frequency)

      #return if block.call == true
      r = block.call
      return r if r

      break if Time.now - start > timeout
    end

    fail "timeout after #{timeout}s"
  end
  alias :wait_for :wait_until

  def new_safe_array

    []
      .tap { |a| a.extend(JRuby::Synchronized) if jruby? }
  end
end

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
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

    #so = StringIO.new
    #  .tap { |io| PP.pp(o, io, 67) }.string.gsub(/^/, ' ' * 2)
    #sactual = StringIO.new
    #  .tap { |io| PP.pp(actual, io, 67) }.string.gsub(/^/, ' ' * 2)
    so = (o == nil) ? '  nil' : Flor.tree_to_pp_s(o).gsub(/^/, ' ' * 2)
    sactual = Flor.tree_to_pp_s(actual).gsub(/^/, ' ' * 2)

    "expected:\n" + so + "\n\ngot:\n" + sactual
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

RSpec::Matchers.define :include_msg do |o|

  h = o.inject({}) { |hh, (k, v)| hh[k.to_s] = v; hh }

  match do |actual|

    return false unless actual.is_a?(Array)
    return false unless actual.all? { |e| e.is_a?(Hash) }

    !! actual.find { |m| h.all? { |k, v| m.has_key?(k) && m[k] == v } }
  end

  failure_message do |actual|

    "did not find message matching #{Flor.message_to_s(h)}\n" +
    "  in\n" +
    actual.collect { |m| "    #{Flor.message_to_s(m)}\n" }.join
  end

  failure_message_when_negated do |actual|

    "did find message #{Flor.message_to_s(h)}\n" +
    "  in\n" +
    actual.collect { |m| "    #{Flor.message_to_s(m)}\n" }.join
  end
end

RSpec::Matchers.define :point_to do |path|

  apath = File.absolute_path(path)

  match do |actual|

    actual == apath
  end

  failure_message do |actual|

    actual = '(nil)' if actual == nil
    ppath = ' ' * (apath.length - path.length) + path

    "expected\n  #{actual}\n\nto point to\n  #{ppath}\n  #{apath}"
  end
end

class RSpec::Core::ExampleGroup
  #
  # for spec/parser_spec.rb

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

      contexts.each do |c, li_ra_ru_pn_s|

        context(c) do

          li_ra_ru_pn_s.each do |li, fl, ru, st|

            ra = fl.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
            ra = "#{ra[0, 60]}..." if ra.length > 60
            title = "parses li#{li} `#{ra}`"

            ru = Kernel.eval(ru)

            if st == :hidden
              # do nothing
            elsif st == :pending
              pending(title)
            else
              it(title) {
                expect(
                  RSpec::Core::ExampleGroup.replace_head(Flor.parse(fl))
                ).to eqt(
                  ru
                )
              }
            end
          end
        end
      end
    end

    def replace_head(t)

      t[0] = '_head_XXX' if t[0].is_a?(String) && t[0].match(/\A_head_/)
      t[1].each { |st| replace_head(st) } if t[1].is_a?(Array)

      t
    end
  end
end

class String

  def ftrim

    self.split("\n")
      .inject([]) { |a, l|
        l = l.match(/\A\s*([^#]*)/)[1].rstrip
        a << l unless l.empty?
        a }
      .join("\n")
  end
end

class Hash

  def test_each(context)

    max = self.keys.collect { |k| k.strip.length }.max + 2

    self.each do |k, v|

      k = k.strip

      context
        .so "%-#{max}.#{max}s yields #{v.inspect}" % [ "`#{k}`", v.inspect ] do

          @executor ||= Flor::TransientExecutor.new

          r = @executor.launch(k)

          expect(r['point']).to eq('terminated')
          expect(r['payload']).to eq({ 'ret' => v })
        end
    end
  end
end

class Array

  def test_each_fail(context, error_message, opts={})

    self.each do |c|

      c = c.strip

      context
        .it "fails for `#{c}`" do

          @executor ||= Flor::TransientExecutor.new

          r = @executor.launch(c)

          expect(r['point']).to eq('failed')

          if error_message.is_a?(Regexp)
            expect(r['error']['msg']).to match(error_message)
          else
            expect(r['error']['msg']).to eq(error_message)
          end

          if lin = opts[:lin]
            expect(r['error']['lin']).to eq(lin)
          end
        end
    end
  end
end

