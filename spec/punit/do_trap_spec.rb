
#
# specifying flor
#
# Mon Mar  5 06:51:26 JST 2018
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_do_trap'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'do_trap' do

    it 'traps messages' do

      r = @unit.launch(
        %q{
          sequence
            do-trap 'terminated'
              trace "terminated(f:$(msg.from))"
            trace "here($(node.nid))"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.traces.count > 1 }

      expect(
        @unit.traces.collect(&:text).join("\n")
      ).to eq(%w[
        here(0_1_0_0_1_0_0)
        terminated(f:0)
      ].collect(&:strip).join("\n"))

      ms = @unit.journal
      m0 = ms.find { |m| m['point'] == 'terminated' }
      m1 = ms.find { |m| m['point'] == 'trigger' }

      expect(m1['sm']).to eq(m0['m'])
    end
  end
end

