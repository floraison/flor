
#
# specifying flor
#
# Thu Jan  7 06:22:04 JST 2016
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

  describe 'val' do

    it 'returns values on their own' do

      #@flor.storage.connection.loggers << Logger.new($stdout)
      #@flor.on(nil, nil, nil) { |msg| puts "*** msg *** #{msg.inspect}" }

      cmp = %{
        2
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

