
#
# specifying flor
#
# Sat May 14 07:02:08 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_sleep'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'sleep' do

    it 'creates a timer' do

      flor = %{
        sleep '1y'
      }

      r = @unit.launch(flor, wait: '0 schedule')

      expect(r['point']).to eq('schedule')
      expect(r['type']).to eq('in')
      expect(r['string']).to eq('1y')

      exid = r['exid']

      sleep 0.140

      ts = @unit.timers.all
      t = ts.first
      td = t.data

      expect(ts.count).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.type).to eq('in')
      expect(t.schedule).to eq('1y')
      expect(t.ntime_t.year).to eq(Time.now.utc.year + 1)

      expect(td['message']['point']).to eq('receive')
    end

    it 'understands for:' do

      flor = %{
        sleep for: '2y'
      }

      r = @unit.launch(flor, wait: '0 schedule')

      expect(r['point']).to eq('schedule')
      expect(r['type']).to eq('in')
      expect(r['string']).to eq('2y')

      exid = r['exid']

      sleep 0.140

      ts = @unit.timers.all
      t = ts.first
      td = t.data

      expect(ts.count).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.type).to eq('in')
      expect(t.schedule).to eq('2y')
      expect(t.ntime_t.year).to eq(Time.now.utc.year + 2)

      expect(td['message']['point']).to eq('receive')
    end

    it 'fails when missing a duration' do

      flor = %{
        sleep _
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('failed')
      expect(msg['error']['msg']).to eq('missing a sleep time duration')
    end

#    it 'does not sleep when t <= 0' do
#
#      flor = %{
#        sleep '0s'
#      }
#
#      exid = @unit.launch(flor, wait: true)
#
#      sleep 0.140
#
#      expect(@unit.journal.find { |m| m['point'] == 'schedule' }).to eq(nil)
#
#      expect(@unit.executions.terminated.count).to eq(1)
#
#      e = @unit.executions.terminated.first
#
#      if jruby?
#        expect(e.data['duration']).to be < 0.777 + 1.4
#      else
#        expect(e.data['duration']).to be < 0.777
#      end
#
#      expect(@unit.timers.count).to eq(0)
#    end
  #
  # No, it must at least "skip a beat" so that
  # a) the code is simpler, same for "sleep 0s" and "sleep 100y";
  # b) "sleep 0s" can be used, to well, "skip a beat"...

    it 'makes an execution sleep for a while' do

      flor = %{
        sleep '1s'
      }

      r = @unit.launch(flor, wait: '0 schedule')

      expect(r['point']).to eq('schedule')

      exid = r['exid']

      sleep 0.140

      expect(@unit.timers.count).to eq(1)

      @unit.wait(exid, 'terminated')

      sleep 0.140

      expect(@unit.executions.terminated.count).to eq(1)

      e = @unit.executions.terminated.first

      expect(e.data['duration']).to be > 1.0
      expect(e.data['counters']['runs']).to eq(2)

      expect(@unit.timers.count).to eq(0)
    end
  end
end

