
#
# specifying flor
#
# Fri Feb 26 17:33:04 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'push' do

    it 'takes the first child as target' do

      r = @executor.launch(
        %q{
          true
          push f.l
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true ])
      expect(r['payload']['ret']).to eq(true)
    end

    it 'fails if it cannot push to the first child' do

      r = @executor.launch(
        %q{
          1
          push f.l
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('cannot push to given target (NilClass)')
      expect(r['error']['prc']).to eq('push')
      expect(r['error']['lin']).to eq(3)
    end

    it 'pushes f.ret by default' do

      r = @executor.launch(
        %q{
          "le silence"
          push f.l
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 'le silence' ])
      expect(r['payload']['ret']).to eq('le silence')
    end

    it 'pushes the value of the last child' do

      r = @executor.launch(
        %q{
          0
          push f.l 1
          push f.l 1 2
          push f.l 1 2
            3
          push f.l 1 2
            3
            4
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 1, 2, 3, 4 ])
      expect(r['payload']['ret']).to eq(0)
    end

    it 'leaves the current f.ret intact' do

      r = @executor.launch(
        %q{
          'de la mer'
          push f.l 1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['payload']['ret']).to eq('de la mer')
    end

    it 'pushes' do

      r = @executor.launch(
        %q{
          0
          push f.l
            + 0 1
          push f.l
            + 1 2
          push f.l \ + 2 3
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 1, 3, 5 ])
      expect(r['payload']['ret']).to eq(0)
    end

    it 'pushes nulls' do

      r = @executor.launch(
        %q{
          push f.l null
          push f.l 0
          #
          null
          push f.l
          push f.l 1
          #
          push f.l
            null
          push f.l 2
          #
          push f.l f.nada
          push f.l 3
          #
          push f.l
            f.nada
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ nil, 0, nil, 1, nil, 2, nil, 3, nil ])
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  describe 'pushr' do

    it 'returns the pushed value' do

      r = @executor.launch(
        %q{
          'vercors'
          pushr f.l 2
        }, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 2 ])
      expect(r['payload']['ret']).to eq(2)
    end
  end
end

