
#
# specifying flor
#
# Mon Dec 21 16:50:23 JST 2020
#

require 'spec_helper'


describe Flor::ModuleGanger do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'modgangspec'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe '#task' do

    it 'tasks' do

      r = @unit.launch(
        %{
          karamel _
          task 'mofon'
        },
        domain: 'kilo',
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('mofon')
      expect(r['payload']['seen']).to eq(%w[ karamel mofon ])
    end
  end

  describe '#detask' do

    it 'detasks' do

      r = @unit.launch(
        %{
          kink _
        },
        domain: 'kilo',
        wait: 'task')

      exid = r['exid']

      @unit.cancel(exid: exid, nid: '0')

      r = @unit.wait(exid)#, 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'cancelled' => [ 'kink' ] })
    end
  end
end

