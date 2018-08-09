
#
# specifying flor
#
# Wed Jun  1 13:37:07 JST 2016
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

  describe 'a timeout' do

    it 'sets a timer' do

      exid = @unit.launch(
        %q{
          sequence
            stall timeout: 60
        })

      wait_until { @unit.timers.count > 0 }

      ts = @unit.timers.all
      t = ts.first
      d = t.data

      expect(ts.size).to eq(1)

      expect(t.exid).to eq(exid)
      expect(t.nid).to eq('0_0')
      expect(t.type).to eq('in')
      expect(t.schedule).to eq('60')
      expect(t.status).to eq('active')
      expect(t.count).to eq(0)

      expect(d['point']).to eq('schedule')
      expect(d['from']).to eq('0_0_0')
      expect(d['message']['point']).to eq('cancel')
      expect(d['message']['nid']).to eq('0_0')
      expect(d['message']['from']).to eq('0_0_0')
      expect(d['message']['flavour']).to eq('timeout')
    end

    it 'triggers after the given time' do

      r = @unit.launch(
        %q{
          sequence
            stall timeout: "1s"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(@unit.timers.count).to eq(0)

      m = @unit.journal.find { |mm| mm['point'] == 'cancel' }

      expect(m['nid']).to eq('0_0')
      expect(m['from']).to eq('0_0_0')
      expect(m['flavour']).to eq('timeout')
      expect(m['payload']).to eq({ 'ret' => '1s' })
    end

    it 'is removed if the node ends before timing out' do

      exid = @unit.launch(
        %q{
          sleep '1s' timeout: '2.8s'
        })

      wait_until { @unit.timers.count > 1 }

      expect(
        @unit.timers.collect { |t|
          [ t.nid, t.data['message']['point'] ].join('/')
        }
      ).to eq(
        %w[ 0/cancel 0/receive ]
      )

      @unit.wait(exid, 'terminated')

      wait_until { @unit.timers.count < 1 }

      expect(@unit.timers.count).to eq(0)

      expect(@unit.journal.last['point']).to eq('end')
      expect(@unit.journal.select { |m| m['point'] == 'cancel' }.size).to eq(0)
    end
  end
end

