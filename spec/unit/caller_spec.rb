
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
            %w[ cwd kla msg trc ])
          expect(r[0]['kla']).to eq(
            'NameError')
          expect(r[0]['msg']).to match(
            /\Auninitialized constant (Kernel::)?Does\z/)
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
          expect(r[0].keys.sort).to eq(%w[ cwd kla msg trc ])
          expect(r[0]['kla']).to eq('RuntimeError')
          expect(r[0]['msg']).to eq('pure fail at m:67')
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
          expect(r[0].keys.sort).to eq(%w[ cwd kla msg trc ])
          expect(r[0]['kla']).to eq('Errno::ENOENT')
          expect(r[0]['msg']).to eq('No such file or directory - cobra')
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
          expect(r[0].keys.sort).to eq(%w[ cwd kla msg trc ])
          expect(r[0]['kla']).to eq('Flor::Caller::SpawnError')
          expect(r[0]['msg']).to match(/\A\(code: 2, pid: \d+\) /)
          expect(r[0]['msg']).to match(/ python: can't open file 'spec\/unit\//)
          expect(r[0]['msg']).to match(/ \[Errno 2\] No such file or directory/)
        end
      end
    end
  end
end

