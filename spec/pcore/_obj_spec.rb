
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
      expect(r['payload']['ret']).to eqd({})
    end

    it 'works  {} tag: t' do

      r = @executor.launch(%{ {} tag: 't' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({})

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
      expect(r['payload']['ret']).to eqd({ 'a' => 'A' })

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
      expect(r['payload']['ret']).to eqd({ '7' => 'sept' })
    end

    it 'does not evaluate variable keys' do

      r = @executor.launch(
        %q{
          set a "colour"
          { a: 'yellow', if: false }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'yellow', if: false })
    end

    it 'evaluate keys (v.a and f.b)' do

      r = @executor.launch(
        %q{ { a: 1, b: 2, v.a: "A", f.b: "B" } },
        payload: { 'b' => 'bravo' },
        vars: { 'a' => 'alpha' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 1, b: 2, alpha: 'A', bravo: 'B' })
    end

    it 'evaluates keys (_dqs)' do

      r = @executor.launch(
        %q{
          set a "color"
          { "$(a)s": [ 'yellow' 'blue' ] }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ colors: %w[ yellow blue ] })
    end

  # keys are now (2019-01-01) quoted by default, see above.
  #
#    context "quote: 'keys'" do
#
#      it 'does not evaluate keys' do
#
#        r = @executor.launch(
#          %q{
#            set a "colour"
#            { a: 'red', (a _): 'green' } quote: 'keys'
#          })
#
#        expect(r['point']).to eq('terminated')
#        expect(r['payload']['ret']).to eqd({ a: 'red', colour: 'green' })
#      end
#    end
  end
end

