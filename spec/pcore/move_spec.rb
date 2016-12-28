
#
# specifying flor
#
# Fri Dec 23 06:51:12 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'move' do

    it 'fails if the target cannot be found' do

      flon = %{
        cursor
          push f.l 'a'
          move to: 'final'
          push f.l 'b'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq(%w[ a ])

      expect(r['error']['msg']).to eq('move target "final" not found')
    end

    it 'moves to a tag' do

      flon = %{
        cursor
          push f.l 'a'
          move to: 'final'
          push f.l 'b'
          push f.l 'c' tag: 'final'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    it 'moves to a string argument' do

      flon = %{
        cursor
          push f.l 'a'
          move to: 'c'
          push f.l 'b'
          push f.l 'c'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    it 'moves to a string' do

      flon = %{
        cursor
          push f.l 'a'
          move to: 'c'
          push f.l 'b'
          "c"
          push f.l 'd'
          move to: 'f'
          push f.l 'e'
          'f'
          push f.l 'g'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a d g ])
    end

    it 'moves to a name' do

      flon = %{
        define here; noret
        define there; noret
        cursor
          push f.l 'a'
          move to: 'here'
          push f.l 'b'
          here _
          push f.l 'c'
          move to: 'there'
          push f.l 'd'
          there
          push f.l 'e'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c e ])
    end

    it 'accepts a symbol as to:' do

      flon = %{
        cursor
          push f.l 'a'
          move to: here
          push f.l 'b'
          _ here
          push f.l 'c'
      }

      r = @executor.launch(flon, payload: { 'l' => [] }, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    it 'can move a cursor by its tag name' do

      flon = %{
        set l []
        concurrence
          cursor tag: 'x0'
            push l 'a'
            stall _
            push l 'b'
          sequence
            push l 0
            move 'x0' to: 'b'
            push l 1
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 'a', 1, 'b' ])

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
end

