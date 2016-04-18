
#
# specifying flor
#
# Fri Feb 26 11:58:57 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'dollar extrapolation' do

    it 'substitutes heads' do

      rad = %{
        set f.a "sequ"
        set f.b "ence"
        "$(f.a)$(f.b)"
          push f.l 1
          push f.l 2
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 1, 2 ])
      expect(r['payload']['ret']).to eq(2)
    end

    it "doesn't get in the way of regexps" do

      rad = %{
        push f.l
          match "car", /^[bct]ar$/
        push f.l
          match "car", "^[bct]ar$"
      }

      r = @executor.launch(rad, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ car ], %w[ car ] ])
    end
  end
end

