
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

#    it 'fails with a ParseError if the conf is invalid' do
#
#      File.open(@path, 'wb') do |f|
#        f.write(%q{
#require 'alpha.rb'
#class: AlphaTasker
#        })
#      end
#
#      unit = Flor::Unit.new('envs/test/etc/conf.json')
#      unit.conf['unit'] = 'taskertypo'
#      #@unit.hook('journal', Flor::Journal)
#      unit.storage.delete_tables
#      unit.storage.migrate
#      unit.start
#
#      m = unit.launch(
#        %q{
#          alpha _
#        },
#        wait: true)
#pp m
#    end
  end
end

