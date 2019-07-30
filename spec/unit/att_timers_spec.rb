
#
# specifying flor
#
# Thu Jul  4 18:10:04 JST 2019  Neyruz, chez Grand-Maman (départ St-Martin)
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'uatimers'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'timer:/timers:' do

    context 'string' do

      it 'sets timers' do

        exid = @unit.launch(
          %q{
            define remind
              "remember!"
            stall timer: '60 remind'
            #stall timer: [ '60' remind ]
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
    end
  end
end

