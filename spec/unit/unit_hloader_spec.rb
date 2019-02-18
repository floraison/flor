
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
      [ { 'age' => 20 } ] => 20,
      [ { 'age' => 20 }, 'org.example' ] => 20,
      [ { 'org.example.age' => 21 } ] => :fail,
      [ { 'age' => 19, 'org.example.age' => 21 } ] => 19,
      [ { 'org.example.age' => 21 }, 'org.example.accounting' ] => 21,

    }.each do |(h, dom), ret|

      it "works with variable conf #{h.inspect}" do

        h.each do |k, v|
          #@unit.loader.add(:variable, k, v)
          @unit.add_var(k, v)
        end

        r = @unit.launch(
          %{
            #{h.keys.last.split('.').last}
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

    it "works with a block tasker conf" do

      @unit.add_tasker('alice') do
        payload['ret'] = 'signed Alice.'
        reply
      end

      r = @unit.launch(
        %q{
          alice _
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq('signed Alice.')
    end

    {
      [ { 'flow0' => %q{ 1234 } } ] => 1234,
      [ { 'domain0.flow0' => %q{ 1234 } } ] => 1234,
      [ { 'sub:flow0' => %q{ 1234 } } ] => 1234,

    }.each do |(h, dom), ret|

      it "works with library conf #{h.keys.inspect}" do

        h.each do |path, flow|
          if m = path.match(/\Asub(?:flows?)?:(.+)\z/)
            @unit.add_sub(m[1], flow)
          else
            @unit.add_lib(path, flow)
          end
        end

        th = h.keys.last.split(/[:.]/).last

        r = @unit.launch(
          %{
            sequence
              import '#{th}'
          },
          domain: dom,
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(ret)
      end
    end

    [
      :replaceme

    ].each do |hook_conf|

      it "works with hook conf #{hook_conf.inspect}"
    end
  end
end

