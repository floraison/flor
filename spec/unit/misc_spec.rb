
#
# specifying flor
#
# Fri Mar 24 10:47:50 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'misc'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'concurrence vs every' do

    # ```
    # concurrence
    #   alpha 'do this'
    #   every '5s'
    #     alpha 'do that'
    # ```
    # fails funnily
    # and resists cancelling

    it 'cancels without a hitch (before scheduling)' do

      flor = %{
        concurrence
          hole 'a'
          every '2s'
            hole 'b'
      }

      r = @unit.launch(flor, wait: 'schedule')
      r = @unit.cancel(exid: r['exid'], nid: '0', wait: true)

      expect(r['point']).to eq('terminated')
    end

    it 'cancels without a hitch (after scheduling)' do

      flor = %q{
        concurrence
          hole 'a'
          every '1s' \ hole 'b'
      }

      r = @unit.launch(flor, wait: 'task;trigger;task')
      sleep 0.5
      @unit.cancel(exid: r['exid'], nid: '0')
      r = @unit.wait(r['exid'], 'ceased;terminated')

      expect(r['point']).to eq('terminated')
    end
  end
end

