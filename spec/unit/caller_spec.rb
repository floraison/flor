
#
# specifying flor
#
# Tue Mar 14 16:41:37 JST 2017
#

require 'spec_helper'


describe Flor::Caller do

  before :all do

    @caller = Flor::Caller.new(nil)
  end

  describe '#call' do

    context 'ruby' do

      it 'calls basic ruby classes' do

        r = @caller.call(
          nil,
          { 'require' => 'unit/hooks/for_caller',
            'class' => 'Romeo::Callee',
            '_path' => 'spec/' },
          { 'point' => 'execute', 'm' => 1 })

        expect(r).to eq([ { 'point' => 'receive', 'mm' => 2 } ])
      end

      context 'on call error' do

        it 'returns a failed message' do

          r = @caller.call(
            nil,
            { 'require' => 'unit/hooks/for_caller',
              'class' => 'Does::Not::Exist',
              '_path' => 'spec/' },
            { 'point' => 'execute', 'm' => 1 })

          expect(r.class).to eq(Array)
          expect(r.size).to eq(1)

          expect(r[0].keys.sort).to eq(
            %w[ error fm fpoint point ])
          expect(r[0]['error']['kla']).to eq(
            'NameError')
          expect(r[0]['error']['msg']).to match(
            /\Auninitialized constant (Kernel::)?Does\b/)
        end
      end

      context 'on error' do

        it 'returns a failed message' do

          r = @caller.call(
            nil,
            { 'require' => 'unit/hooks/for_caller',
              'class' => 'Romeo::Failer',
              '_path' => 'spec/' },
            { 'point' => 'execute', 'm' => 67 })

          expect(r.class).to eq(Array)
          expect(r.size).to eq(1)
          expect(r[0].keys.sort).to eq(%w[ error fm fpoint point ])
          expect(r[0]['error']['kla']).to eq('RuntimeError')
          expect(r[0]['error']['msg']).to eq('pure fail at m:67')
        end
      end
    end

    context 'external' do

      it 'calls basic scripts' do

        r = @caller.call(
          nil,
          { 'cmd' => 'python spec/unit/hooks/for_caller.py',
            '_path' => 'spec/' },
          { 'point' => 'execute',
            'payload' => { 'items' => 2 } })

        expect(
          r
        ).to eq([
          { 'point' => 'receive',
            'payload' => { 'items' => 2, 'price' => 'CHF 5.00' } }
        ])
      end

      it 'calls basic scripts (with arguments)' do

        r = @caller.call(
          nil,
          { 'cmd' => 'python spec/unit/hooks/for_caller.py "hello python"',
            '_path' => 'spec/' },
          { 'point' => 'execute',
            'payload' => { 'items' => 2 } })

        expect(
          r
        ).to eq([
          { 'argument' => 'hello python',
            'point' => 'receive',
            'payload' => { 'items' => 2, 'price' => 'CHF 5.00' } }
        ])
      end

      it 'calls basic scripts (with env var)' do

        r = @caller.call(
          nil,
          { 'cmd' => 'ENV_VAR=hello python spec/unit/hooks/for_caller.py',
            '_path' => 'spec/' },
          { 'point' => 'execute',
            'payload' => { 'items' => 2 } })

        expect(
          r
        ).to eq([
          { 'env_var' => 'hello',
            'point' => 'receive',
            'payload' => { 'items' => 2, 'price' => 'CHF 5.00' } }
        ])
      end

      context 'on call error' do

        it 'returns a failed message' do

          r = @caller.call(
            nil,
            { 'cmd' => 'cobra spec/unit/hooks/for_caller.py',
              '_path' => 'spec/' },
            { 'point' => 'execute',
              'payload' => { 'items' => 2 } })

          expect(r.class).to eq(Array)
          expect(r.size).to eq(1)
          expect(r[0].keys.sort).to eq(%w[ error fm fpoint payload point ])

          e = r[0]['error']
#pp e
          expect(e['kla']).to eq('Flor::Caller::WrappedSpawnError')
          expect(e['msg']).to match(/No such file or directory/)

          ed = e['details']
          expect(ed[:cmd]).to eq('cobra spec/unit/hooks/for_caller.py')
          expect(ed[:pid]).to eq(nil)
          expect(ed[:timeout]).to eq(14)
        end
      end

      context 'on exit code != 1' do

        it 'returns a failed message' do

          r = @caller.call(
            nil,
            { 'cmd' => 'python spec/unit/hooks/no_such_caller.py',
              '_path' => 'spec/' },
            { 'point' => 'execute',
              'payload' => { 'items' => 2 } })

          expect(r.class).to eq(Array)
          expect(r.size).to eq(1)
          expect(r[0].keys.sort).to eq(%w[ error fm fpoint payload point ])

          e = r[0]['error']

          expect(e['kla']
            ).to eq('Flor::Caller::SpawnNonZeroExitError')
          expect(e['msg']
            ).to match(/\A\(code: 2, pid: \d*\) /)
          expect(e['msg']
            ).to match(/[Pp]ython: can't open file '.*spec\/unit\/hooks\//)
          expect(e['msg']
            ).to match(/ \[Errno 2\] No such file or directory/)

          ed = e['details']
          expect(ed[:cmd]).to eq('python spec/unit/hooks/no_such_caller.py')
          expect(ed[:pid]).to be_an(Integer) if ed[:pid] # ;-)
          expect(ed[:timeout]).to eq(14)
        end
      end

      context 'on timeout' do

        it 'fails' do

          t0 = Time.now

          r = @caller.call(
            nil,
            { 'cmd' => 'ruby -e "sleep"',
              '_path' => 'spec/',
              'timeout' => '2s' },
            { 'point' => 'execute', 'payload' => {} })

          expect(r.class).to eq(Array)
          expect(r.size).to eq(1)
          expect(r[0].keys.sort).to eq(%w[ error fm fpoint payload point ])

          e = r[0]['error']
#pp e
          expect(e['kla']
            ).to eq('Flor::Caller::WrappedSpawnError')
          expect(e['msg']
            ).to eq('wrapped: Flor::Caller::TimeoutError: execution expired')

          ed = e['details']
          pid = ed[:pid]

          expect(ed[:cmd]).to eq('ruby -e "sleep"')
          expect(ed[:pid]).to be_an(Integer) if pid
          expect(ed[:timeout]).to eq(2)
          expect(ed[:conf]['timeout']).to eq('2s')

          expect(ed[:cause]
            ).to eq(
              kla: 'Flor::Caller::TimeoutError',
              msg: 'execution expired')

          expect(`ps -p #{pid}`.strip.split("\n").size).to eq(1) if pid
            # ensure child process has vanished
        end
      end
    end
  end
end

