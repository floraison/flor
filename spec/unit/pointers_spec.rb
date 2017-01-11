
#
# specifying flor
#
# Wed Jan 11 13:47:07 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'the pointers table' do

    it 'points to executions by tag name' do

      r =
        @unit.launch(%{
          concurrence
            stall tag: 'a'
            stall tag: 'b'
        }, wait: '0_1 entered')
      i0 = r['exid']
      expect(r['point']).to eq('entered')

      r =
        @unit.launch(%{
          concurrence
            stall tag: 'a'
            stall tag: 'c'
        }, wait: '0_1 entered')
      i1 = r['exid']
      expect(r['point']).to eq('entered')

      sleep 0.350

      exes = @unit.executions.by_tag('a')

      expect(exes.collect(&:exid).sort).to eq([ i0, i1 ].sort)
    end

    it 'points to executions by task name'
    it 'points to executions by tasked name'
    it 'points to executions by var name'
    it 'points to executions by var name and value'

    it 'removes pointers to terminated executions' do

      r =
        @unit.launch(%{
          sequence tag: 'a'
        }, wait: true)
      exid = r['exid']

      expect(r['point']).to eq('terminated')

      expect(@unit.pointers.count).to eq(0)
    end
  end
end

