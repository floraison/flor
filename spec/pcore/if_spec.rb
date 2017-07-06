
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

  describe 'if' do

    it 'has no effect if it has no children' do

      r = @executor.launch(
        %q{
          sequence
            123
            push f.l 0
            if _
            push f.l 1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(123)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'simply sets $(ret) if there are no then/else children' do

      r = @executor.launch(
        %q{
          sequence
            456
            if
              true
            push f.l
            if
              false
            push f.l
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(456)
      expect(r['payload']['l']).to eq([ 456, 456 ])
    end

    it 'triggers the then child when $(ret) true' do

      r = @executor.launch(
        %q{
          sequence
            if
              true
              push f.l 0
              push f.l 1
            push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) false' do

      r = @executor.launch(
        %q{
          sequence
            if
              false
              push f.l 0
              push f.l 1
            push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end

    it 'does not mind atts on the if' do

      r = @executor.launch(
        %q{
          if false tag: 'nada'
            'then'
            'else'
        })

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

      r = @executor.launch(
        %q{
          push f.l (if true 'then' 'else')
          push f.l (if false 'then' 'else')
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq(%w[ then else ])
    end
  end

  describe 'unless' do

    it 'triggers the then child when $(ret) false' do

      r = @executor.launch(
        %q{
          sequence
            unless
              false
              push f.l 0
              push f.l 1
            push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ 0, 2 ])
    end

    it 'triggers the else child when $(ret) true' do

      r = @executor.launch(
        %q{
          sequence
            unless
              true
              push f.l 0
              push f.l 1
            push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 1, 2 ])
    end
  end
end

