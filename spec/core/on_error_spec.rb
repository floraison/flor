
#
# specifying flor
#
# Wed Jul 20 17:04:44 JST 2016 Tcheliabinsk
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'the on_error: attribute' do

    it 'has no effect when no error' do

      r = @executor.launch(
        %q{
          sequence on_error: (def msg, err \ _)
            push f.l 0
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'fails if the handler does not exist' do

      r = @executor.launch(
        %q{
          sequence on_error: nada
            push f.l 0
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('cannot find "nada"')
    end

    it 'triggers when a child has an error' do

      r = @executor.launch(
        %q{
          sequence on_error: (def msg, err \ push f.l err.msg)
            push f.l 0
            push f.l x
            push f.l 1
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ 0, "cannot find \"x\"" ])
    end

    it 'triggers when it has an error' do

      r = @executor.launch(
        %q{
          push f.l x on_error: (def msg \ push f.l msg.error.msg)
        },
        payload: { 'l' => [ -1 ] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ -1, "cannot find \"x\"" ])
    end

    it 'accepts the name of a function' do

      r = @executor.launch(
        %q{
          define mute err \ 'muted.'
          sequence on_error: mute
            push f.l 0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']).to eq({ 'ret' => 'muted.' })
    end

    it 'accepts a function that returns a function' do

      r = @executor.launch(
        %q{
          define return x
            def msg, err
              x
          sequence on_error: (return 2)
            push f.l 0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(2)
    end

    it 'does not loop' do

      r = @executor.launch(
        %q{
          define r
            y _
          sequence on_error: r
            x _
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('don\'t know how to apply "y"')
    end

    it 'does not mind nested error handlers' do

      r = @executor.launch(
        %q{
          define rr
            push f.l 'rr'
          define r
            sequence on_error: rr
              y _
          sequence on_error: r
            x _
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ 'rr' ])

      expect(
        @executor.journal
          .select { |m| m['point'] == 'failed' }
          .count
      ).to eq(
        2
      )
    end

    it 'does not mind nested error handlers (2)' do

      r = @executor.launch(
        %q{
          define r0
            push f.l 'r0'
          define r1
            push f.l 'r1'
            y _
          sequence on_error: r0
            sequence on_error: r1
              x _
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ 'r1', 'r0' ])

      expect(
        @executor.journal
          .select { |m| m['point'] == 'failed' }
          .count
      ).to eq(
        2
      )
    end
  end
end

