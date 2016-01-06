
#
# specifying flor
#
# Thu Jan  7 06:33:21 JST 2016
#

require 'spec_helper'


describe 'Flor a to z' do

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

  context 'an error' do

    it 'is raised upon encountering an unkown instruction' do

      #@flor.storage.connection.loggers << Logger.new($stdout)
      #@flor.on(nil, nil, nil) { |msg| puts "*** msg *** #{msg.inspect}" }

      cmp = %{
        nada
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

