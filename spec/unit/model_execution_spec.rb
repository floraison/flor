
#
# specifying flor
#
# Tue Oct  9 21:06:06 JST 2018
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

  describe 'Execution model' do

    describe '#to_h' do

      it 'details the execution' do

        exid =
          @unit.launch(%{
            concurrence
              stall _
              fail 'nada'
              bravo 'do the job'
              nemo
          })

        execution = wait_until {
          @unit.executions.first(exid: exid) }

        h = execution.to_h
        d = h[:data]
        m = h[:meta]

        expect(h[:size]).to be_between(770, 910)

        expect(m[:counts][:nodes]).to eq(5)
        expect(m[:counts][:tasks]).to eq(1)
        expect(m[:counts][:failures]).to eq(2)
      end
    end
  end
end

