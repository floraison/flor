
#
# specifying flor
#
# Sun Apr  3 14:11:49 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'matchr' do

    it "returns empty array when it doesn't match" do

      flor = %{
        matchr "alpha", /bravo/
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => [] })
    end

    it "returns the array of matches" do

      flor = %{
        push f.l
          matchr "stuff", /stuf*/
        push f.l
          matchr "stuff", /s(tu)(f*)/
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ stuff ], %w[ stuff tu ff ] ])
    end

    it 'turns the second argument into a regular expression' do

      flor = %{
        push f.l
          #match? "stuff", "^stuf*$"
          matchr "stuff", "stuf*"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ stuff ] ])
    end

    context 'single argument' do

      it 'takes $(f.ret) as the string' do

        flor = %{
          "blue moon" | matchr (/blue/) | push l
          "blue moon" | matchr 'moon' | push l
          "blue moon" | match? 'moon' | push l
          "blue moon" | match? 'x' | push l
        }

        r = @executor.launch(flor, vars: { 'l' => [] })

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq([ %w[ blue ], %w[ moon ], true, false ])
      end
    end
  end

  describe 'match?' do

    it 'works alongside "if"' do

      flor = %{
        push f.l
          if
            match? "stuff", "^stuf*$"
            'a'
            'b'
        push f.l
          if
            match? "staff", "^stuf*$"
            'c'
            'd'
        push f.l
          if
            match? "$(nothing)", "^stuf*$"
            'e'
            'f'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a d f ])
    end
  end

  #describe 'starts_with' do
  #  it 'works'
  #end
  #describe 'ends_with' do
  #  it 'works'
  #end
end

