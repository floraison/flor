
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

  describe '_obj' do

    it 'works  {}' do

      r = @executor.launch(%{ {} })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({})
    end

    it 'works  {} tag: t' do

      r = @executor.launch(%{ {} tag: 't' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({})

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

    it 'works  { "a": "A" }' do

      r = @executor.launch(%{ { 'a': 'A' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'A' })

      expect(@executor.journal.size).to eq(3)
    end

    it 'works  { "a": "A" } tag: t' do

      r = @executor.launch(%{ { 'a': 'A' } tag: 't' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'a' => 'A' })

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

      expect(@executor.journal.size).to eq(11)
    end

    it 'works  { a: "A" }' do

      r = @executor.launch(%{ { a: 'A' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'A' })
    end

    it 'turns keys to strings' do

      r = @executor.launch(%{ { 7: 'sept' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ '7' => 'sept' })
    end

    it 'evaluates keys' do

      r = @executor.launch(
        %q{
          set a "colour"
          { a: 'yellow' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'colour' => 'yellow' })
    end

    it 'evaluates keys (_dqs)' do

      r = @executor.launch(
        %q{
          set a "color"
          { "$(a)s": [ 'yellow' 'blue' ] }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'colors' => %w[ yellow blue ] })
    end

    context "quote: 'keys'" do

      it 'does not evaluate keys' do

        r = @executor.launch(
          %q{
            set a "colour"
            { a: 'red', (a _): 'green' } quote: 'keys'
          })

        expect(r['point']).to eq(
          'terminated')
        expect(r['payload']['ret']).to eq(
          { 'a' => 'red', 'colour' => 'green' })
      end
    end
  end
end

