
#
# specifying flor
#
# Wed Jul 20 05:21:41 JST 2016 outake ryoukan
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'a tasker' do

    it 'can be "applied" directly' do

      flon = %{
        alpha
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_task', 'alpha', -1 ]
      )
    end

    it 'can be "applied" directly' do

      flon = %{
        alpha _
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
      expect(r['payload']['seen'][0]).to eq('alpha')
      expect(r['payload']['seen'][1]).to eq('AlphaTasker')
    end

    it 'passes attributes'
  end
end

