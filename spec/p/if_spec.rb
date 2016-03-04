
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
          push f.l
            f.ret
          if
            =
              3
              3
          push f.l
            f.ret
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ false, true ])
    end

    it 'triggers its children in sequence if the condition is true'
    it 'skips its children if the condition is true'
    it 'plays nicely with "then" and "else"'
  end

  describe 'unless' do

    it 'inverts $(f.ret)'
  end
end
