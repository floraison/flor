
#
# specifying flor
#
# Sat Feb 16 12:00:00 JST 2019
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
      lambda { payload['ret'] = 'Alice was here'; reply }

    ].each do |tasker_conf|

      tc = tasker_conf
      if tc.is_a?(Proc)
        f, l = tc.source_location
        tc = File.readlines(f)[l - 1].strip
      end

      it "works with tasker conf #{tc.inspect}" do

        if tasker_conf.is_a?(Proc)
          @unit.add_tasker('alice', &tasker_conf)
        else
          #@unit.loader.add(:tasker, 'alice', tasker_conf)
          @unit.add_tasker('alice', tasker_conf)
        end

        r = @unit.launch(
          %q{
            alice _
          },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq('Alice was here')
      end
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

    class UnitHloaderHook0
      #def opts; { consumed: false }; end
      def on_message(m)
#p m['consumed']
        m['payload']['ret'] = 'uhlh0' # invasive hook
        [] # no new messages
      end
    end

    {
      [ '', UnitHloaderHook0 ] => 'uhlh0',
      [ '', { point: 'execute', class: UnitHloaderHook0 } ] => 'uhlh0',
      [ '', lambda { |m| m['payload']['ret'] = 'l0' } ] => 'l0',

    }.each do |(dompath, hook_conf, dom), ret|

      hc = hook_conf
      if hc.is_a?(Proc)
        f, l = hc.source_location
        hc = File.readlines(f)[l - 1].match(/ (lambda.+\}) \] =>/)[1]
      end

      it "works with hook conf #{hc.inspect}" do

        if hook_conf.is_a?(Proc)
          @unit.add_hook(dompath, &hook_conf)
        else
          @unit.add_hook(dompath, hook_conf)
        end

        r = @unit.launch(
          %{
            sequence
              sequence _
          },
          domain: dom,
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(ret)
      end
    end
  end
end

