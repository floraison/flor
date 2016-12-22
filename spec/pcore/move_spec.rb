
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

    it 'moves to a string' do

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

    it 'moves to a name'
  end
end

