
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

      r = @executor.launch(
        %q{
          set l []
          concurrence
            until false tag: 'x0'
              push l 0
              stall _
            sequence
              push l 1
              break ref: 'x0'
        })

      expect(r).to have_terminated_as_point
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

      r = @executor.launch(
        %q{
          set l []
          concurrence
            cursor tag: 'x0'
              push l 0
              stall _
            sequence
              push l 1
              break ref: 'x0'
        })

      expect(r).to have_terminated_as_point
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

      r = @executor.launch(
        %q{
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
        })

      expect(r).to have_terminated_as_point
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

      r = @executor.launch(
        %q{
          set l []
          concurrence
            cursor tag: 'x'
              push l 'a'
              stall _
            sequence
              push l 'b'
              continue ref: 'x'
              push l 'c'
              break ref: 'x'
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(nil)
      expect(r['vars']['l']).to eq(%w[ b a c a ])
    end
  end

  describe 'break vs on_cancel:' do

    it 'does not bite its tail' do

      @executor.launch(
        %q{
          push f.l 0
          cursor
            stall on_cancel: (def \ break 'break-on-cancel')
            push f.l 1
          push f.l 2
        },
        payload: { 'l' => [] })

      m = @executor.journal.last

      expect(m['payload']['l']).to eq([ 0 ])

      m = @executor.walk([
        { 'point' => 'cancel', 'nid' => m['nid'], 'exid' => @executor.exid } ])

      expect(m).to have_terminated_as_point
      expect(m['payload']['l']).to eq([ 0, 2 ])
      expect(m['payload']['ret']).to eq('break-on-cancel')
    end
  end
end

