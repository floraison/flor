
#
# specifying flor
#
# Mon Feb 20 17:54:35 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'reapply'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 're-applying a node' do

    it 'works' do

      flor = %{
        sequence
          stall _
      }

      r = @unit.launch(flor, wait: '0_0 receive')
      exid = r['exid']

      sleep 0.350

      new_tree = %{
        sequence
          alpha _
      }

      @unit.re_apply(exid: exid, nid: '0_0', tree: new_tree)

      r = @unit.wait(exid, 'terminated')

pp r
    end
  end
end

