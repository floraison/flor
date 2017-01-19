
#
# specifying flor
#
# Thu Jan 19 21:15:23 SGT 2017  Singapore
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker name key' do

    it 'keys on the tasker name' do

      flo = %{
        _dump alpha: 'V'
      }

      r = @unit.launch(flo, wait: true)

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ alpha V ] ])
    end
  end

  describe 'a tasker invocation as key' do

    it 'keys on the invocation result' do

      flo = %{
        _dump (alpha _): 'V'
        _dump (delta _): 'V'
      }

      r = @unit.launch(flo, wait: true)

      expect(r['point']).to eq('terminated')

      dump = r['vars']['dumps'][0]

      expect(dump['node']['atts']).to eq([ %w[ alpha V ] ])

      dump = r['vars']['dumps'][1]

      expect(dump['node']['atts']).to eq([ %w[ dimitri V ] ])
    end
  end
end

