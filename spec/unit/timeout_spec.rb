
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

      flor = %{
        sequence
          stall timeout: 60
      }

      exid = @unit.launch(flor)

      sleep 0.777

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

      flor = %{
        sequence
          stall timeout: "1s"
      }

      t0 = Time.now

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')

      expect(@unit.timers.count).to eq(0)

      can = @unit.journal.find { |m| m['point'] == 'cancel' }

      expect(can['nid']).to eq('0_0')
      expect(can['from']).to eq('0_0_0')
      expect(can['flavour']).to eq('timeout')
      #expect(can['payload']).to eq(Flor::Ash.compute_ash({ 'ret' => '1s' }))
      expect(can['payload']).to eq({ 'ret' => '1s' })
    end

    it 'is removed if the node ends before timing out' do

      flor = %{
        sleep '1s' timeout: '2.8s'
      }

      exid = @unit.launch(flor)

      sleep 0.490

      expect(
        @unit.timers.collect { |t|
          [ t.nid, t.data['message']['point'] ].join('/')
        }
      ).to eq(
        %w[ 0/cancel 0/receive ]
      )

      @unit.wait(exid, 'terminated')
      sleep 0.280

      expect(@unit.timers.count).to eq(0)

      expect(@unit.journal.last['point']).to eq('end')
      expect(@unit.journal.select { |m| m['point'] == 'cancel' }.size).to eq(0)
    end
  end
end

