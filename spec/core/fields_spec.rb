
#
# specifying flor
#
# Wed Apr 26 05:42:07 JST 2017
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a field reference' do

    it 'yields the value' do

      flor = %{
        f.key
      }

      r = @executor.launch(flor, payload: { 'key' => 'c major' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['key']).to eq('c major')
      expect(r['payload']['ret']).to eq('c major')
    end

    it 'yields null else'# do
#
#      flor = %{
#        f.key
#      }
#
#      r = @executor.launch(flor)
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq(nil)
#    end
  end

  describe 'a field deep reference' do

    it 'yields the desired value' do

      flor = %{
        set f.c f.a.0
        f.a.0.b
      }

      r = @executor.launch(flor, payload: { 'a' => [ { 'b' => 'c' } ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['c']).to eq({ 'b' => 'c' })
      expect(r['payload']['ret']).to eq('c')
    end
  end
end

