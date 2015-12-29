
#
# specifying flor
#
# Wed Dec 30 08:06:35 JST 2015
#

require 'spec_helper'


describe 'Flor::Mnemo' do

  describe '.to_s' do

    it 'turns positive integers to mnemo strings' do

      expect(Flor::Mnemo.to_s(0)).to eq('ba')
      expect(Flor::Mnemo.to_s(1)).to eq('bi')
      expect(Flor::Mnemo.to_s(99)).to eq('zo')
      expect(Flor::Mnemo.to_s(100)).to eq('biba')
      expect(Flor::Mnemo.to_s(101)).to eq('bibi')
      expect(Flor::Mnemo.to_s(392406)).to eq('kogochi')
      expect(Flor::Mnemo.to_s(25437225)).to eq('haleshuha')
    end

    it 'turns negative integers to mnemo strings' do

      expect(Flor::Mnemo.to_s(-1)).to eq('xabi')
      expect(Flor::Mnemo.to_s(-99)).to eq('xazo')
      expect(Flor::Mnemo.to_s(-100)).to eq('xabiba')
    end
  end

  describe '.to_i' do

    it 'rejects strings that are not mnemo strings' do

      expect {
        Flor::Mnemo.to_i('blah blah blah')
      }.to raise_error(ArgumentError, "unknown syllable 'bl'")

      expect {
        Flor::Mnemo.to_i('xabixabi')
      }.to raise_error(ArgumentError, "unknown syllable 'xa'")
    end

    it 'turns mnemo strings to integers' do

      expect(Flor::Mnemo.to_i('yoshida')).to eq(947110)
      expect(Flor::Mnemo.to_i('bajo')).to eq(34)
      expect(Flor::Mnemo.to_i('xabaji')).to eq(-31)
      expect(Flor::Mnemo.to_i('tonukatsu')).to eq(79523582)
    end
  end
end

