
#
# specifying flor
#
# Fri Mar  4 09:27:47 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'if' do

    it 'evaluates its first child as conditional' do

      rad = %{
        sequence
          if
            =
              1
              2
          push f.l f.ret
          if
            =
              3
              3
          push f.l f.ret
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ false, true ])
    end

    it 'triggers its children in sequence if the condition is true' do

      rad = %{
        if
          true
          push f.l 0
          push f.l 1
        push f.l 2
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'skips its children if the condition is false' do

      rad = %{
        if
          false
          push f.l 0
          push f.l 1
        push f.l 2
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
      expect(r['payload']['l']).to eq([ 2 ])
    end

    it 'plays nicely with "then" and "else"' do

      rad = %{
        sequence
          if
            false
          then
            push f.l 0
          else
            push f.l 1
          push f.l 2
          if
            true
          then
            push f.l 3
          else
            push f.l 4
          push f.l 5
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(5)
      expect(r['payload']['l']).to eq([ 1, 2, 3, 5 ])
    end
  end

  describe 'unless' do

    it 'inverts $(f.ret)' do

      rad = %{
        sequence
          unless
            =
              1
              2
          push f.l f.ret
          unless
            =
              3
              3
          push f.l f.ret
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'triggers its children' do

      rad = %{
        sequence
          unless
            false
            push f.l 0
            push f.l 1
          push f.l 2
          unless
            true
            push f.l 3
            push f.l 4
          push f.l 5
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(5)
      expect(r['payload']['l']).to eq([ 0, 1, 2, 5 ])
    end

    it 'plays nicely with "then" and "else"' do

      rad = %{
        sequence
          unless
            false
          then
            push f.l 0
          else
            push f.l 1
          push f.l 2
          unless
            true
          then
            push f.l 3
          else
            push f.l 4
          push f.l 5
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(5)
      expect(r['payload']['l']).to eq([ 0, 2, 4, 5 ])
    end
  end
end

