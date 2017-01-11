
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

      expect(exes.collect(&:exid)).to eq([ i0, i1 ])
    end

    it 'points to executions by task name'
    it 'points to executions by tasked name'
    it 'points to executions by var name'
    it 'points to executions by var name and value'

    it 'removes pointers to terminated executions'

#    it 'lists the current tags' do
#
#      r =
#        @unit.launch(%{
#          concurrence
#            sequence tag: 'aa'
#              stall _
#            sequence tag: [ 'bb', 'cc' ]
#              stall _
#        }, wait: '0_1_1_0_0 execute')
#
#      expect(r['point']).to eq('execute')
#
#      sleep 0.490
#
#      exe = @unit.executions[exid: r['exid']]
#
#      expect(exe.tags).to eq(%w[ aa bb cc ])
#    end
  end
end

