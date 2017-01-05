
#
# specifying flor
#
# Thu Jan  5 07:17:48 JST 2017  Ishinomaki
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_schedule'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'schedule' do

    it 'creates a timer' do

      flor = %{
        schedule cron: '0 0 1 jan *'
          def msg; alpha
      }

      exid = @unit.launch(flor)

      sleep 1

      exe = @unit.executions[exid: exid]

      expect(exe.failed?).to eq(false)

      expect(exe).not_to eq(nil)

      ts = @unit.timers.all
      t = ts.first

      expect(ts.count).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.type).to eq('cron')
      expect(t.schedule).to eq('0 0 1 jan *')
      expect(t.ntime_t.localtime.year).to eq(Time.now.utc.year + 1)

      td = t.data

      expect(td['message']['point']).to eq('execute')
      expect(td['message']['tree'][0]).to eq('_apply')
    end

    context 'cron' do

      it 'triggers repeatedly' do

        flor = %{
          set count 0
          schedule cron: '* * * * * *' # every second
            def msg
              set count (+ count 1)
        }

        exid = @unit.launch(flor)

        sleep 1.9

        expect(@unit.timers.count).to eq(1)

        t = @unit.timers.first
#p Flor.tstamp
#p t.values.reject { |k, v| k == :content }

        expect(t.schedule).to eq('* * * * * *')
        expect(t.count).to be > 0
        pc = t.count

        sleep 1.4

        expect(@unit.timers.count).to eq(1)

        t = @unit.timers.first
#p Flor.tstamp
#p t.values.reject { |k, v| k == :content }

        expect(t.count).to be > pc
      end
    end
  end
end

