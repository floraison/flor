
#
# specifying flor
#
# Sat Mar  5 13:46:23 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'ife' do

    it 'has no effect it it has no children' do

      flon = %{
        sequence
          123
          push f.l 0
          ife _
          push f.l 1
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(123)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'simply sets $(ret) if there are no then/else children' do

      flon = %{
        sequence
          456
          ife
            true
          push f.l
          ife
            false
          push f.l
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(456)
      expect(r['payload']['l']).to eq([ 456, 456 ])
    end

    it 'triggers the then child when $(ret) true' do

      flon = %{
        sequence
          ife
            true
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) false' do

      flon = %{
        sequence
          ife
            false
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end

    it 'does not mind atts on the ife' do

      flon = %{
        ife false tag: 'nada'
          'then'
          'else'
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('else')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:nada
        receive:0:
        execute:0_1:
        receive:0:
        execute:0_3:
        receive:0:
        receive::
        left:0:nada
        terminated::
      ].join("\n"))
    end

    it 'can be used as a "one-liner"' do

      flon = %{
        push f.l (ife true 'then' 'else')
        push f.l (ife false 'then' 'else')
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq(%w[ then else ])
    end
  end

  describe 'unlesse' do

    it 'triggers the then child when $(ret) false' do

      flon = %{
        sequence
          unlesse
            false
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) true' do

      flon = %{
        sequence
          unlesse
            true
            push f.l 0
            push f.l 1
          push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end
  end
end

