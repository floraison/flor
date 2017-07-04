
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

      r = @executor.launch(
        %q{
          _dump 3: 12
          _dump []: 12
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ [ 3, 12 ] ])

      dump = r['vars']['dumps'][1]

      expect(dump['node']['atts']).to eq([ [ [], 12 ] ])
    end
  end

  describe 'an attribute key referencing a var' do

    it 'it keys on the var value' do

      r = @executor.launch(
        %q{
          set k 'K'
          _dump k: 'V'
        })

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ K V ] ])
    end
  end

  describe 'an attribute key referencing a function' do

    it 'is keys on the function name' do

      r = @executor.launch(
        %q{
          define k \ stall _
          _dump k: 'V'
        })

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ k V ] ])
    end

    it 'is keys on the referenced function name' do

      r = @executor.launch(
        %q{
          define k \ stall _
          set kk k
          _dump kk: 'V'
        })

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ kk V ] ])
    end
  end

  describe 'an attribute key calling a function' do

    it 'keys on the return value' do

      r = @executor.launch(
        %q{
          define k; 'K'
          _dump (k _): 'V'
        })

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ K V ] ])
    end
  end
end

