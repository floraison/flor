
#
# specifying flor
#
# Sat May 14 07:02:08 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf')
    @unit.conf[:unit] = 'pu_sleep'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'sleep' do

    it 'creates a timer' do

      flon = %{
        sleep '1y'
      }

      exid = @unit.launch(flon)

      sleep 0.350

      ts = @unit.timers.all
      t = ts.first
      td = t.data

      expect(ts.count).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.type).to eq('in')
      expect(t.schedule).to eq('1y')
      expect(t.ntime.year).to eq(Time.now.year + 1)

      expect(td['message']['point']).to eq('receive')
    end

    it 'understands for:' do

      flon = %{
        sleep for: '2y'
      }

      exid = @unit.launch(flon)

      sleep 0.350

      ts = @unit.timers.all
      t = ts.first
      td = t.data

      expect(ts.count).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.type).to eq('in')
      expect(t.schedule).to eq('2y')
      expect(t.ntime.year).to eq(Time.now.year + 2)

      expect(td['message']['point']).to eq('receive')
    end

    it 'fails when missing a duration' do

      flon = %{
        sleep _
      }

      msg = @unit.launch(flon, wait: true)

      expect(msg['point']).to eq('failed')
      expect(msg['error']['msg']).to eq('missing a sleep time duration')
    end

    it 'does not sleep when t <= 0'

    it 'makes an execution sleep for a while' do

      flon = %{
        sleep '1s'
      }

      exid = @unit.launch(flon)

      sleep 0.350

      expect(@unit.storage.db[:flon_timers].count).to eq(1)
      #expect(@unit.storage.db[:flon_waiters].count).to eq(0)
        # TODO eventually

      sleep 1.4

      expect(@unit.executions.terminated.count).to eq(1)

      e = @unit.executions.terminated.first

      expect(e.data['duration']).to be > 1.0

      expect(@unit.storage.db[:flon_timers].count).to eq(0)
      #expect(@unit.storage.db[:flon_waiters].count).to eq(0)
        # TODO
    end
  end
end

