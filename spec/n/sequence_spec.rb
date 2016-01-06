
#
# specifying flor
#
# Thu Jan  7 06:29:29 JST 2016
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

  describe 'sequence' do

    it 'returns immediately when empty'

    it 'returns the last value' do

      #@flor.storage.connection.loggers << Logger.new($stdout)
      #@flor.on(nil, nil, nil) { |msg| puts "*** msg *** #{msg.inspect}" }

      flo = %{
        sequence
          1
          2
      }

      exid = @flor.launch("#{@dom}.#{__LINE__}", flo, {})

      r = @flor.wait(exid, :terminated, nil)

      expect(r['point']).to eq('terminated')
      expect(r['exid']).to eq(exid)
      expect(r['from']).to eq(nil)
      expect(r['payload']).to eq({ 'ret' => 2 })
      expect(r['n']).to eq(6)
    end
  end
end

