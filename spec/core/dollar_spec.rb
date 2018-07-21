
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

    it "substitutes $(node) (not really useful)" do

      r = @executor.launch(
        %q{
          push f.l "nid:$(node.nid)"
          push f.l "heat0:$(node.heat0)"
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ nid:0_0_1_1_0_0 heat0:_ref ])
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
      expect(r['payload']['l']).to eq([ 'b', '["b","c"]', '["a","c","e"]' ])
    end

    {

      '$(brown)' => 'fox',
      '.$(brown).' => '.fox.',
      '$(brown) $(lazy)' => 'fox dog',
      '$( "$(l)$(z)" )' => 'lazy',
      '$( v["$(l)$(z)"] )' => 'dog',
      '<$(blue)>' => '<>',
      '$(arr)' => '[1,2,3]',
      '$(hsh)' => JSON.dump({ 'a' => 'A', 'b' => 'B' }),
      'a$(arr)z' => 'a[1,2,3]z',
      'a$(hsh)z' => 'a{"a":"A","b":"B"}z',
      'a)b' => 'a)b',
      '$xxx' => '$xxx',
      'x$xxx' => 'x$xxx',
      '$(hsh["a"])' => 'A',
      '^[bct]ar$\"' => '^[bct]ar$"',

      # or
      '$(brown||lazy)' => 'fox',
      '$(nada||lazy)' => 'dog',
      '$(nada||"$(lazy)")' => 'dog',
      '$(nada||\'$(lazy)\')' => '$(lazy)',

      # pipe
      '$( bs | downcase _ )' => 'black sheep',
      '$( bs | upcase _ )' => 'black sheep'.upcase,
      '$( ba | reverse _ )' => 'black adder'.reverse,

    }.each do |dqs, ret|

      it "extrapolates \"#{dqs}\" to #{ret.inspect}" do

        vars = {
          'brown' => 'fox',
          'lazy' => 'dog',
          'quick' => 'jump',
          'l' => 'la',
          'z' => 'zy',
          'black' => 'PuG',
          'func' => 'u',
          'ba' => 'black adder',
          'bs' => 'bLACK shEEp',
          'msg' => '"hello world"',
          'msg1' => 'hello "le monde"',
          'arr' => [ 1, 2, 3 ],
          'hsh' => { 'a' => 'A', 'b' => 'B' },
          'amount' => 1234 }

        r = @executor.launch(
          %{
            "#{dqs}"
          },
          vars: vars)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(ret)
      end
    end
  end
end

