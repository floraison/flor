
#
# specifying flor
#
# Fri Feb 26 11:58:57 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'dollar extrapolation' do

    it 'substitutes heads' do

      r = @executor.launch(
        %q{
          set f.a "sequ"
          set f.b "ence"
          "$(f.a)$(f.b)"
            push f.l 1
            push f.l 2
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 1, 2 ])
      expect(r['payload']['ret']).to eq('sequence')
    end

    it "doesn't get in the way of regexps" do

      r = @executor.launch(
        %q{
          push f.l
            matchr "car", /^[bct]ar$/
          push f.l
            matchr "car", "^[bct]ar$"
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ car ], %w[ car ] ])
    end

    it "substitutes $(node)" do

      r = @executor.launch(
        %q{
          push f.l "$(node.nid)"
          push f.l "$(node.heat0)"
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_1 _dqs ])
    end

    it "indexes arrays" do

      r = @executor.launch(
        %q{
          push f.l "$(f.a[1])"
          push f.l "$(f.a[1,2])"
          push f.l "$(f.a[:7:2])"
        },
        payload: { 'a' => %w[ a b c d e f ], 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 'b', %w[ b c ], %w[ a c e ] ])
    end
  end
end

