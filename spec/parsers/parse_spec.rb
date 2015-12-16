
#
# specifying flor
#
# Sat Dec 12 07:05:15 JST 2015
#

require 'spec_helper'


describe Flor::Json do

  context 'numbers' do

    [
      [ '1', 1 ],
      [ '-1', -1 ],
      [ '123', 123 ],
      [ '0.0', 0.0 ],
      [ '10.01', 10.01 ],
      [ '1.5e2', 150 ]
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end

  context 'strings' do

    [
      [ '"hello"', 'hello' ],
      [ '"hello \"old bore\""', 'hello "old bore"' ],
      [ '"hello\ttab"', "hello\ttab" ],
      [ '"hello \z"', nil ],
      [ '"hello\nalpha"', "hello\nalpha" ],
      [ "\"hello\\nbravo\"", "hello\nbravo" ],
      [ '"hello \u0066ool"', "hello fool" ]
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end

  context 'single-quoted strings' do

    [
      [ "'bonjour'", 'bonjour' ],
      [ "'bonjour \\'vieux bavard\\''", "bonjour 'vieux bavard'" ],
      [ "'bonjour\\ttab'", "bonjour\ttab" ]
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end

  context 'booleans' do

    [
      [ 'true', true ],
      [ 'false', false ]
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end

  context 'null' do

    [
      [ 'null', nil ],
    ].each do |a|

      it "parses #{a[0].inspect}" do

        #expect(Flor::Json.parse(a[0], debug: 1)).to eq(a[1])
        expect(Flor::Json.parse(a[0])).to eq(a[1])
      end
    end
  end
end

