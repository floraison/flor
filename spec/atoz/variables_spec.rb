
#
# specifying flor
#
# Thu Mar 31 16:17:39 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a variable as head' do

    it 'is derefenced upon application' do

      flon = %{
        set f.a
          sequence
        #$(f.a)
        f.a
          1
          2
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end
  end

  describe 'a variable deep reference' do

    it 'yields the desired value' do

      flon = %{
        set f.c f.a.0
        f.a.0.b
      }

      r = @executor.launch(flon, payload: { 'a' => [ { 'b' => 'c' } ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['c']).to eq({ 'b' => 'c' })
      expect(r['payload']['ret']).to eq('c')
    end
  end
end

