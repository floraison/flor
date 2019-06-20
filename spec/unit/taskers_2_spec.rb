
#
# specifying flor
#
# Wed Jun 12 21:32:47 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  describe 'a tasker with a typo in its configuration' do # gh-23

    before :each do
      @path = 'envs/test/lib/taskers/alpha/dot.json'
      @original = File.read(@path)
      @apath = File.absolute_path(@path)
    end
    after :each do
      File.open(@path, 'wb') { |f| f.write(@original) }
    end

    it 'fails with an ArgumentError if the configuration is not a Hash' do

      File.open(@path, 'wb') do |f|
        f.write(%q{
require 'alpha.rb'
class AlphaTasker
        })
      end

      unit = Flor::Unit.new('envs/test/etc/conf.json')
      unit.conf['unit'] = 'taskertypo'
      #@unit.hook('journal', Flor::Journal)
      unit.storage.delete_tables
      unit.storage.migrate
      unit.start

      m = unit.launch(
        %q{
          alpha _
        },
        wait: true)

      expect(m['point']).to eq('failed')
      expect(m['error']['kla']).to eq('ArgumentError')
      expect(m['error']['msg']).to eq('tconf "require" not a hash')
    end

    it 'fails with a ParseError if the conf is invalid' do

      File.open(@path, 'wb') do |f|
        f.write(%q{
require 'alpha.rb'
class: AlphaTasker
        })
      end

      unit = Flor::Unit.new('envs/test/etc/conf.json')
      unit.conf['unit'] = 'taskertypo'
      unit.hook('journal', Flor::Journal)
      unit.storage.delete_tables
      unit.storage.migrate
      unit.start

      m = unit.launch(
        %q{
          alpha _
        },
        wait: true)

      expect(m['point']
        ).to eq('failed')
      expect(m['m']
        ).to eq(2)
      expect(m['error']['kla']
        ).to eq('Flor::ParseError')
      expect(m['error']['msg']
        ).to eq("syntax error at line 1 column 1 in #{@apath}")

      sleep 0.420

      expect(unit.journal.map { |m| m['point'] }).to eq(%w[ failed end ])
    end
  end

  describe 'a tasker with a require: in its configuration' do # gh-24

    before :each do

STDOUT.sync = true
ENV['FLOR_DEBUG'] = 'stdout,dbg' if jruby?
      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf['unit'] = 'ut2r'
      #@unit.hook('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start

      @tasker_path = 'envs/test/lib/taskers/ted.rb'
      @constant_path = 'envs/test/lib/taskers/ted_constant.rb'

      File.open(@tasker_path, 'wb') do |f|
        f.write(%{
          class TedTasker < Flor::BasicTasker
            def task
              message['payload']['ted'] = 'was here'
              message['payload']['constant'] = Flor::CONSTANT \
                if defined?(Flor::CONSTANT)
              reply
            end
          end
        })
      end
    end

    after :each do

      @unit.shutdown

      FileUtils.rm(@tasker_path)
      FileUtils.rm(@constant_path) rescue nil

      Flor.send(:remove_const, 'CONSTANT') if defined?(Flor::CONSTANT)
ENV.delete('FLOR_DEBUG')
    end

    it 'requires from the Ruby loadpath' do

      File.open(@tasker_path, 'ab') do |f|
        f.write(%q{
          { require: 'flor', class: 'TedTasker' }
        })
      end

      m = @unit.launch(
        %q{
          ted _
        },
        wait: true)

      expect(m['point']).to eq('terminated')

      expect(m['payload']).to eq({
        'ret' => 'ted', 'ted' => 'was here' })
    end

    it 'requires from the flor environment' do

      File.open(@tasker_path, 'ab') do |f|
        f.write(%q{
          { require: 'ted_constant', class: 'TedTasker' }
        })
      end
      File.open(@constant_path, 'wb') do |f|
        f.write(%q{
          Flor::CONSTANT = 'ted req'
        })
      end

      m = @unit.launch(
        %q{
          ted _
        },
        wait: true)

      expect(m['point']).to eq('terminated')

      expect(m['payload']).to eq({
        'ret' => 'ted', 'ted' => 'was here', 'constant' => 'ted req' })
    end
  end

  describe 'a tasker with a load: in its configuration' do # gh-24

    before :each do

      @unit = Flor::Unit.new('envs/test/etc/conf.json')
      @unit.conf['unit'] = 'ut2l'
      #@unit.hook('journal', Flor::Journal)
      @unit.storage.delete_tables
      @unit.storage.migrate
      @unit.start

      @tasker_path = 'envs/test/lib/taskers/ted.rb'
      @constant_path = 'envs/test/lib/taskers/ted_constant.rb'

      File.open(@tasker_path, 'wb') do |f|
        f.write(%{
          class TedTasker < Flor::BasicTasker
            def task
              message['payload']['ted'] = 'was here'
              message['payload']['constant'] = Flor::CONSTANT \
                if defined?(Flor::CONSTANT)
              reply
            end
          end
        })
      end
    end

    after :each do

      @unit.shutdown

      FileUtils.rm(@tasker_path)
      FileUtils.rm(@constant_path) rescue nil

      Flor.send(:remove_const, 'CONSTANT') if defined?(Flor::CONSTANT)
    end

    it 'loads from the Ruby loadpath' do

      File.open(@tasker_path, 'ab') do |f|
        f.write(%q{
          { load: 'flor.rb', class: 'TedTasker' }
        })
      end

      m = @unit.launch(
        %q{
          ted _
        },
        wait: true)

      expect(m['point']).to eq('terminated')

      expect(m['payload']).to eq({
        'ret' => 'ted', 'ted' => 'was here' })
    end

    it 'loads from the flor environment' do

      File.open(@tasker_path, 'ab') do |f|
        f.write(%q{
          { load: 'ted_constant.rb', class: 'TedTasker' }
        })
      end
      File.open(@constant_path, 'wb') do |f|
        f.write(%q{
          Flor::CONSTANT = 'ted load'
        })
      end

      m = @unit.launch(
        %q{
          ted _
        },
        wait: true)

      expect(m['point']).to eq('terminated')

      expect(m['payload']).to eq({
        'ret' => 'ted', 'ted' => 'was here', 'constant' => 'ted load' })
    end
  end
end

