
#
# specifying flor
#
# Sun Jul 10 06:48:32 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'a hook' do

    it 'is given the opportunity to see any message' do

      msgs = []
      @unit.hook do |message|
        msgs << Flor.dup(message) if message['consumed']
      end

      @unit.launch(%{
        sequence
          noop _
      }, wait: true)

      expect(msgs).to eq(@unit.journal)
    end

    it 'may alter a message' do

      @unit.hook do |message|
        next if message['consumed']
        next unless message['point'] == 'execute'
        message['tree'][1] = 'blue' if message['tree'][0] == '_sqs'
      end

      @unit.launch(%{
        sequence
          trace 'red'
      }, wait: true)

      expect(
        @unit.traces.collect { |t| "#{t.nid}:#{t.text}" }
      ).to eq(%w[
        0_0:blue
      ])
    end
  end

  describe 'Flor::Scheduler#hook' do

    it 'may filter on consumed:/c:' do

      ncms = []; @unit.hook(consumed: false) { |m| ncms << Flor.dup(m) }
      cms = []; @unit.hook(c: true) { |m| cms << Flor.dup(m) }
      ms = []; @unit.hook { |m| ms << Flor.dup(m) }

      @unit.launch(%{
        sequence
          noop _
      }, wait: true)

      expect([ ms.size, cms.size, ncms.size ]).to eq([ 14, 7, 7 ])
    end

    it 'may filter on point:/p:' do

      ms0 = []
      @unit.hook(point: 'execute') { |m| ms0 << Flor.dup(m) }
      ms1 = []
      @unit.hook(p: %w[ execute terminated ]) { |m| ms1 << Flor.dup(m) }

      @unit.launch(%{
        sequence
          noop _
      }, wait: true)

      expect(
        ms0.collect { |m| m['point'] }.uniq).to eq(%w[ execute ])
      expect(
        ms1.collect { |m| m['point'] }.uniq).to eq(%w[ execute terminated ])
    end
  end
end

