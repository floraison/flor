
#
# specifying flor
#
# Fri Jan  8 10:20:21 JST 2016
#

require 'spec_helper'


describe 'Flor instructions' do

  before :each do

    @dom =
      __FILE__[Dir.getwd.length + 1..-9].gsub(/\//, '.')
    @flor =
      Flor::Unit.new(
        storage_uri: 'sqlite://tmp/test.db',
        storage_clean: true)
  end

  after :each do

    @flor.stop
  end

  describe '+' do

    it 'adds numbers' do

      cmp = %{
        +
          1
          1
      }

      exid = @flor.launch("#{@dom}.#{__LINE__}", cmp, {})

      r = @flor.wait(exid, :terminated, nil)

      expect(r['point']).to eq('terminated')
      expect(r['exid']).to eq(exid)
      expect(r['from']).to eq(nil)
      expect(r['n']).to eq(3)
      expect(r['payload']).to eq({ 'ret' => 2 })
    end
  end
end

