
#
# specifying flor
#
# Sun Jul 30 06:15:08 JST 2017  東の家
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u_logger'
  end

  after :each do

    @unit.shutdown
  end

  describe Flor::Logger do

    describe '#initialize' do

      context 'by default' do

        it 'logs to $stdout' do

          @unit.conf.delete('log_out')
          l = Flor::Logger.new(@unit)
          o = l.instance_eval { @out }

          expect(o.class).to eq(Flor::Logger::StdOut)
          expect(o.instance_eval { @f }).to eq($stdout)
        end
      end

      context 'when log_out: false or "null"' do

        it 'logs nowhere' do

          @unit.conf['log_out'] = false
          l = Flor::Logger.new(@unit)
          o = l.instance_eval { @out }

          expect(o.class).to eq(Flor::Logger::NoOut)
        end
      end

      context 'when log_out: 2 or "stderr"' do

        it 'logs to $stderr' do

          @unit.conf['log_out'] = 2
          l = Flor::Logger.new(@unit)
          o = l.instance_eval { @out }

          expect(o.class).to eq(Flor::Logger::StdOut)
          expect(o.instance_eval { @f }).to eq($stderr)
        end
      end

      context 'when log_out: "string"' do

        it 'logs to a file' do

          @unit.conf['log_out'] = 'my_flor_log_dir'
          l = Flor::Logger.new(@unit)
          o = l.instance_eval { @out }

          expect(o.class).to eq(Flor::Logger::FileOut)
          expect(o.instance_eval { @dir }).to eq('my_flor_log_dir')

          expect {
            o.send(:prepare_file)
          }.to raise_error(Errno::ENOENT, /\ANo such file or directory/)
        end
      end

      context 'when log_out: "::ClassName"' do

        it 'logs to a custom Out instance' do

          class ::DummyOut < Flor::Logger::Out
          end

          @unit.conf['log_out'] = 'Flor::DummyOut'
          l = Flor::Logger.new(@unit)
          o = l.instance_eval { @out }

          expect(o.class).to eq(::DummyOut)
          expect(o.instance_eval { @unit }).to eq(@unit)
        end
      end
    end
  end
end

