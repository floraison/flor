
#
# specifying flor
#
# Wed Dec 28 16:57:36 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor pcore' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # NOTA BENE: using "concurrence" even though it's deemed "unit" and not "core"

  describe 'break' do

    it 'breaks an "until" from outside' do

      flor = %{
        set l []
        concurrence
          until false tag: 'x0'
            push l 0
            stall _
          sequence
            push l 1
            break ref: 'x0'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['vars']['l']).to eq([ 1, 0 ])

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_1_0:entered:x0
        0_1_0:left:x0
      ].join("\n"))
    end

    it 'breaks a "cursor" from outside' do

      flor = %{
        set l []
        concurrence
          cursor tag: 'x0'
            push l 0
            stall _
          sequence
            push l 1
            break ref: 'x0'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['vars']['l']).to eq([ 1, 0 ])

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_1_0:entered:x0
        0_1_0:left:x0
      ].join("\n"))
    end
  end

  describe 'continue' do

    it 'continues an "until" from outside' do

      flor = %{
        set l []
        concurrence
          sequence
            set f.i 0
            until tag: 'x0'
              (== f.i 1)
              push l f.i
              stall _
          sequence
            _skip 8
            set f.i 1
            continue ref: 'x0'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['vars']['l']).to eq([ 0 ])

      expect(
        @executor.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['nid'], m['point'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_1_0_1:entered:x0
        0_1_0_1:left:x0
      ].join("\n"))
    end

    it 'continues a "cursor" from outside' do

      flor = %{
        set l []
        concurrence
          cursor tag: 'x'
            push l 'a'
            stall _
          sequence
            _skip 1
            push l 'b'
            continue ref: 'x'
            _skip 1
            push l 'c'
            break ref: 'x'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['vars']['l']).to eq(%w[ a b a c ])
    end
  end
end

