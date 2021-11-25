
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

    sleep 0.770
  end

  after :each do

    @unit.shutdown
  end

  describe 'with hloader' do

    describe '#add_var' do

      {
        [ { 'age' => 20 } ] => 20,
        [ { 'age' => 20 }, 'org.example' ] => 20,
        [ { 'org.example.age' => 21 } ] => :fail,
        [ { 'age' => 19, 'org.example.age' => 21 } ] => 19,
        [ { 'org.example.age' => 21 }, 'org.example.accounting' ] => 21,

      }.each do |(h, dom), ret|

        it "works with conf #{h.inspect}" do

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
    end

    describe '#add_tasker' do

      it 'allows for a Symbol "path"' do

        #@unit.add_tasker('alice', HlAliceTasker)
          # the following is OK too:
        @unit.add_tasker(:alice, HlAliceTasker)

        r = @unit.launch(
          %q{
            alice _
          },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq('Alice was here')
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

        it "works with conf #{tc.inspect}" do

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

      it 'accepts a block' do

        @unit.add_tasker(:alice) { reply(ret: 1 + 2 + 3) }

        r = @unit.launch(
          %q{
            alice _
          },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(6)
      end

      it 'accepts a lambda' do

        @unit.add_tasker(
          :alice,
          lambda { |x| reply(ret: payload['numbers'].reduce(&:+)) })

        r = @unit.launch(
          %q{
            alice _
          },
          payload: { numbers: [ 1, 2, 3 ] },
          wait: true)

        expect(r).to have_terminated_as_point
        expect(r['payload']['ret']).to eq(6)
      end
    end

    describe '#add_sub / #add_lib' do

      {
        [ { 'flow0' => %q{ 1234 } } ] => 1234,
        [ { 'domain0.flow0' => %q{ 1234 } } ] => 1234,
        [ { 'sub:flow0' => %q{ 1234 } } ] => 1234,

      }.each do |(h, dom), ret|

        it "works with conf #{h.keys.inspect}" do

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
    end

    describe '#add_hook' do

      class UnitHloaderHook0
        #def opts; { point: 'execute' }; end
        def on_message(m)
          m['payload']['ret'] = 'uhlh0' \
            if m['payload'] # invasive hook
          [] # no new messages
        end
      end

      class UnitHloaderHook1
        def opts; { consumed: false, point: 'execute' }; end
        def on_message(m)
          m['payload']['ret'] = (m['payload']['ret'] || 0) + 1
          [] # no new messages
        end
      end

      class UnitHloaderHook2
        def opts; { consumed: false, point: 'execute' }; end
        def initialize; @counter = 1; end
        def on_message(m)
          m['payload']['ret'] = @counter = (@counter * 2)
          [] # no new messages
        end
      end

      {
        [ '', UnitHloaderHook0 ] => 'uhlh0',
        [ '', { point: 'execute', class: UnitHloaderHook0 } ] => 'uhlh0',
        [ '', lambda { |m| (m['payload']['ret'] = 'l0') rescue nil } ] => 'l0',
        [ '', UnitHloaderHook1 ] => 3,
        [ '', UnitHloaderHook2.new ] => 8,

      }.each do |(dompath, hook_conf, dom), ret|

        hc = hook_conf
        if hc.is_a?(Proc)
          f, l = hc.source_location
          hc = File.readlines(f)[l - 1].match(/ (lambda.+\}) \] =>/)[1]
        end

        it "works with conf #{hc.inspect}" do

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
end

