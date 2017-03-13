
#
# specifying flor
#
# Tue Mar 14 06:12:19 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'uconfhooks'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a conf hook' do

    after :each do

      FileUtils.rm('envs/test/lib/hooks/dot.json', force: true)
    end

    it 'is handed the matching messages' do

      $seen = []

      hooks = [
        { point: 'receive',
          require: 'unit/hooks/alpha', class: 'AlphaHook' }
      ]

      File.open('envs/test/lib/hooks/dot.json', 'wb') do |f|
        f.puts(Flor.to_djan(hooks, color: false))
      end

      @unit.launch(%{
        sequence
          noret _
      }, wait: true)

      expect($seen.size).to eq(6)
    end

    it 'may alter a message'
  end
end

