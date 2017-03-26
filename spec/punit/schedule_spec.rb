
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

      flor = %q{
        schedule cron: '0 0 1 jan *'
          def msg \ alpha
        stall _
      }

      r = @unit.launch(flor, wait: 'end')
      exid = r['exid']

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
          stall _
        }

        seconds = []

        exid = @unit.launch(flor)#, wait: '0_1 trigger')

        4.times do |i|

          r = @unit.wait(exid, '0_1 trigger')
          seconds << Time.now.sec

          sleep 0.1
          expect(@unit.timers.count).to eq(1)

          t = @unit.timers.first
          expect(t.schedule).to eq('* * * * * *')
          expect(t.count).to eq(1 + i)
        end

        ss = (seconds.first..seconds.first + 3)
          .collect { |s| s % 60 }

        expect(seconds).to eq(ss)
      end
    end

    context 'upon cancellation' do

      it 'cancels its children and replies to its parent' do

        flor = %{
          schedule cron: '* * * * * *' # every second
            def msg
              hole _
          stall _
        }

        r = @unit.launch(flor, wait: 'task')

        exid = r['exid']

        @unit.wait(exid, 'end')

        @unit.cancel(exid: r['exid'], nid: '0')

        @unit.wait(exid, 'detask')
        r = @unit.wait(exid, 'terminated')

        expect(r['point']).to eq('terminated')
      end
    end
  end
end

