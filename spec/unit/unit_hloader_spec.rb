
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

  describe 'with hloader' do

    {
      [ 'age', 20 ] => 20,
      [ 'age', 20, 'org.example' ] => 20,
      [ 'org.example.age', 21 ] => :fail,
      [ 'org.example.age', 21, 'org.example.accounting' ] => 21,

    }.each do |(key, val, dom), ret|

      it "works with variable conf #{key.inspect}, #{val.inspect}" do

        #@unit.loader.add(:variable, 'alice', tasker_conf)
        @unit.add_var(key, val)

        k = key.split('.').last

        r = @unit.launch(
          %{
            #{k}
          },
          domain: dom,
          wait: true)

        if ret == :fail
          expect(r['point']).to eq('failed')
        else
          expect(r).to have_terminated_as_point
          expect(r['payload']['ret']).to eq(ret)
        end
      end
    end

    [
      { class: '::HlAliceTasker' },
      { class: ::HlAliceTasker },
      ::HlAliceTasker,

    ].each do |tasker_conf|

      it "works with tasker conf #{tasker_conf.inspect}" do

        #@unit.loader.add(:tasker, 'alice', tasker_conf)
        @unit.add_tasker('alice', tasker_conf)

        r = @unit.launch(
          %q{
            alice _
          },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq('Alice was here')
      end
    end

    [
      :replaceme

    ].each do |library_conf|

      it "works with library conf #{library_conf.inspect}"
    end

    [
      :replaceme

    ].each do |hook_conf|

      it "works with hook conf #{hook_conf.inspect}"
    end
  end
end

