
#
# specifying flor
#
# Fri Mar 15 16:57:18 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'addbranch'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe '#add_branch' do

    it 'fails immediately if overshooting' do

      r = @unit.launch(
        %q{
          sequence
            stall _
        },
        wait: 'end')

      expect {

        @unit.add_branch(
          exid: r['exid'],
          nid: '0_5',
          tree: %q{ bob 'do important job' })

      }.to raise_error(
        ArgumentError,
        "target 0_5 is off by 4, node 0 has 1 branch"
      )
    end

    it 'fails immediately if the target node is past'

    it 'works inserting in a "sequence"'
    it 'works appending to a "sequence"'

    it 'works appending to a "concurrence"'
  end
end

