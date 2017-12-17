
#
# specifying flor
#
# Fri Feb 26 11:48:09 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_dqs' do

    it 'works with strings' do

      r = @executor.launch(%{ "abc def" })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('abc def')
    end

    it 'works with strings with backslash escapes' do

      r = @executor.launch(%{ "abc\\ndef" })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq("abc\ndef")
    end

    it 'works with strings with backslash escapes for unicode characters'
  end

  describe '_rxs' do

    it 'builds a regular expression' do

      r = @executor.launch(%{ /hello world/i })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ '_rxs', '/hello world/i', 1 ])
    end

    it 'expands the expression' do

      r = @executor.launch(%{ /hello $(f.to)/i }, payload: { 'to' => 'mundo' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ '_rxs', '/hello mundo/i', 1 ])
    end
  end

  describe '_num' do

    it 'works with numbers' do

      r = @executor.launch(%{ 11 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 11 })
    end
  end

  describe '_nul' do

    it 'wraps a nil' do

      r = @executor.launch(%{ null })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })
    end
  end

  describe '_lit' do

    it 'wraps an atom or, hum, a composite' do

      h = { 'a' => 'A', 'b' => [ 0, 1 ], 'c' => false }

      r = @executor.launch([ '_lit', h, 1 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(h)
    end
  end

  describe Flor::Pro::Atom do

    it 'respects tags (_num)' do

      r = @executor.launch(%{ 1 tag: 't' })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_1:entered:t
        0_1:left:t
      ].join("\n"))
    end

    it 'respects tags (_lit)' do

      r = @executor.launch(%{ { 'a': 0 } tag: 't' })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0:entered:t
        0:left:t
      ].join("\n"))
    end
  end
end

