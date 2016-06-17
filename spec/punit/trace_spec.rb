
#
# specifying flor
#
# Mon May 23 10:54:18 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'trace' do

    it 'traces' do

      flon = %{
        trace 'hello'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })

      traces = @unit.traces.all

      expect(traces.count).to eq(1)
      expect(traces[0].exid).to eq(r['exid'])
      expect(traces[0].nid).to eq('0')
      expect(traces[0].tracer).to eq('trace')
      expect(traces[0].text).to eq('hello')
    end

    it 'traces in sequence' do

      flon = %{
        sequence
          trace 'a'
          set x 0
          trace 'b'
          set x 1
          trace 'c'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b c'
      )
    end
  end
end

