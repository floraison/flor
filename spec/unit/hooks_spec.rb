
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

    it 'may alter a message'
  end
end

