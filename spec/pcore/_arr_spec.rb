
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

  describe '_arr' do

    it 'builds an empty array' do

      r = @executor.launch(%{ [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([])
    end

    it 'builds an empty array (with tag)' do

      r = @executor.launch(%{ [] tag: 'x' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([])

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0:entered:x
        0:left:x
      ].join("\n"))

      expect(@executor.journal.size).to eq(13)
    end

    it 'builds an array' do

      r = @executor.launch(%{ [ 1, 2, "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'trois' ])
    end

    it 'builds an array (without commas)' do

      r = @executor.launch(%{ [ 1 2 "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'trois' ])
    end

    it 'builds an array (with commas)' do

      r = @executor.launch(%{ [ 1, 2,, 4 ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 4 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [
          1
          2
        ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [ 1
          2 ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with newlines)' do

      r = @executor.launch(%{
        [ 1
          (2 _) ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2 ])
    end

    it 'builds an array (with vars)' do

      r = @executor.launch(%{
        set b 2
        [ 1 b "c" * b, "d_$(b)" ]
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 'cc', 'd_2' ])
    end

    it 'builds an array (computation with tags)' do

      r = @executor.launch(%{ [ 'un', 1 + 1, "trois" ] tag: 't' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 'un', 2, 'trois' ])

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

      expect(@executor.journal.size).to eq(21)
    end

    it 'builds an array (with tags)' do

      r = @executor.launch(%{ [ 'un', 2, "trois" ] tag: 't' })
      #r = @executor.launch(%{ [] tag: 't' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 'un', 2, 'trois' ])

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
  end
end

