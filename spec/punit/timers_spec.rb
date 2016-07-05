
#
# specifying flor
#
# Mon Jul  4 16:24:35 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_timers'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'timers' do

    it 'sets timers' do

      flon = %{
        sequence
          timers
            reminder 'first reminder' after: '5d'
            timeout after: '9d'
          stall _
      }

      exid = @unit.launch(flon, payload: { 'x' => 'y' })

      sleep 0.350

      ts = @unit.timers.all

      expect(ts.collect(&:nid)).to eq(%w[ 0 0 ])
      expect(ts.collect(&:type)).to eq(%w[ in in ])
      expect(ts.collect(&:schedule)).to eq(%w[ 5d 9d ])

      tds = ts.collect(&:data)
      tms = tds.collect { |td| td['message'] }
      expect(tms.collect { |m| m['point'] }).to eq(%w[ execute execute ])
      expect(tms.collect { |m| m['nid'] }).to eq(%w[ 0_0_0 0_0_1 ])
    end

    it 'fails if there is no parent node' do

      flon = %{
        timers
          reminder 'first reminder' after: '5d'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('no parent node for "timers" at line 2')
    end

    it 'sets timers with after: or in:'
    it 'triggers for its parent node'
  end
end

