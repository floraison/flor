
#
# specifying flor
#
# Thu Jun 16 21:20:42 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown if @unit
  end

  describe 'task' do

    it 'tasks' do

      r = @unit.launch(
        %q{
          task 'alpha'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'].first[0]).to eq('alpha')
      expect(r['payload']['seen'].first[1]).to eq(nil)
      expect(r['payload']['seen'].first[2]).to eq('AlphaTasker')
    end

    it 'can be cancelled' do

      r = @unit.launch(
        %q{
          sequence
            task 'hole'
        },
        payload: { 'song' => 'Marcia Baila' },
        wait: '0_0 task')

      expect(HoleTasker.message['exid']).to eq(r['exid'])

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => r['exid'], 'nid' => '0_0' },
        wait: true)

      expect(HoleTasker.message).to eq(nil)
      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ song holed ])
    end

    it "emits a point: 'return' message" do

      r = @unit.launch(
        %q{
          sequence
            task 'alpha'
        },
        wait: true)

      ret = @unit.journal.find { |m| m['point'] == 'return' }

      expect(ret['nid']).to eq('0_0')
      expect(ret['tasker']).to eq('alpha')
    end

    it "emits a point: 'return' message (backslash)" do

      r = @unit.launch(
        %q{
          sequence \ task 'alpha'
        },
        wait: true)

      ret = @unit.journal.find { |m| m['point'] == 'return' }

      expect(ret['nid']).to eq('0_0')
      expect(ret['tasker']).to eq('alpha')
    end

    it "can reply with an error" do

      r = @unit.launch(
        %q{
          sequence \ task 'failfox'
        },
        wait: true)

      expect(r['nid']).to eq('0_0')
      expect(r['tasker']).to eq('failfox')
      expect(r['point']).to eq('failed')
    end

    it 'passes information to the tasker' do

      r = @unit.launch(
        %q{
          sequence tag: 'a'
            sequence tags: [ 'b', 'c' ]
              india 'do this' temperature: 'high'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      td = r['payload']['tasked'][0]

      expect(td['point']).to eq('task')
      expect(td['nid']).to eq('0_1_1')
      expect(td['taskname']).to eq(nil)
      expect(td['attl']).to eq([ 'india', 'do this' ])
      expect(td['attd']).to eq({ 'temperature' => 'high' })
      expect(td['er']).to eq(1)
      expect(td['m']).to eq(32)
      expect(td['pr']).to eq(1)
      expect(td['vars']).to eq(nil)
      expect(td['tconf']['require']).to eq('india.rb')
      expect(td['tconf']['class']).to eq('IndiaTasker')
      expect(td['tconf']['root']).to eq('envs/test/lib/taskers/india')
      expect(td['tconf']['_path']).to match(/\/lib\/taskers\/india\/dot\.json$/)
    end
  end
end

