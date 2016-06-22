
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

  describe 'match' do

    it "returns false when it doesn't match" do

      flon = %{
        match "alpha", /bravo/
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => [] })
    end

    it "returns the array of matches" do

      flon = %{
        push f.l
          match "stuff", /stuf*/
        push f.l
          match "stuff", /s(tu)(f*)/
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ stuff ], %w[ stuff tu ff ] ])
    end

    it 'turns the second argument into a regular expression' do

      flon = %{
        push f.l
          #match "stuff", "^stuf*$"
          match "stuff", "stuf*"
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ %w[ stuff ] ])
    end
  end

  #describe 'starts_with' do
  #  it 'works'
  #end
  #describe 'ends_with' do
  #  it 'works'
  #end
end

