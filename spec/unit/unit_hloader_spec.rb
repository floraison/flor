
#
# specifying flor
#
# Tue Jan 31 14:41:20 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  class HlAliceTasker < Flor::BasicTasker

    def task

      payload['ret'] = 'Alice was here'

      reply
    end
  end

  before :each do

    @unit = Flor::Unit.new(
      loader: Flor::HashLoader,
      sto_uri: RUBY_PLATFORM.match(/java/) ?
        'jdbc:sqlite://tmp/test.db' : 'sqlite::memory:')
    @unit.conf['unit'] = 'unit_hloader'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'Flor::Unit with hloader' do

    before :each do

      #@unit.loader.add(:tasker, 'alice', '::HlAliceTasker')
      #@unit.loader.add(:tasker, 'alice', ::HlAliceTasker)
      @unit.loader.add(:tasker, 'alice', { class: '::HlAliceTasker' })
      #@unit.loader.add(:tasker, 'alice', { class: ::HlAliceTasker })
    end

    context 'with taskers' do

      it 'hands the task' do

        r = @unit.launch(
          %q{
            alice _
          },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq('Alice was here')
      end
    end
  end
end

