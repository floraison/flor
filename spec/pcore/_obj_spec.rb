
#
# specifying flor
#
# Fri Feb 26 11:48:09 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_obj' do

    it 'works  {}' do

      r = @executor.launch(%{ {} })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({})
    end

    it 'works  { "a": "A" }' do

      r = @executor.launch(%{ { 'a': 'A' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'A' })
    end

    it 'works  { a: "A" }' do

      r = @executor.launch(%{ { a: 'A' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eqd({ a: 'A' })
    end

    it 'turns keys to strings' do

      r = @executor.launch(%{ { 7: 'sept' } })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ '7' => 'sept' })
    end

    it 'evaluates keys' do

      r = @executor.launch(
        %q{
          set a "colour"
          { a: 'yellow' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq({ 'colour' => 'yellow' })
    end

    context "quote: 'keys'" do

      it 'does not evaluate keys' do

        r = @executor.launch(
          %q{
            set a "colour"
            { a: 'red', (a _): 'green' } quote: 'keys'
          })

        expect(r['point']).to eq(
          'terminated')
        expect(r['payload']['ret']).to eq(
          { 'a' => 'red', 'colour' => 'green' })
      end
    end
  end
end

