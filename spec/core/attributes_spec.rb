
#
# specifying flor
#
# Wed Dec 28 11:33:42 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a non-string attribute key' do

    it 'is accepted' do

      flon = %{
        _dump 3: 12
        _dump []: 12
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ [ 3, 12 ] ])

      dump = r['vars']['dumps'][1]

      expect(dump['node']['atts']).to eq([ [ [], 12 ] ])
    end
  end
end

