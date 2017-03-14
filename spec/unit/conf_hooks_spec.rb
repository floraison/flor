
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

    #$: << Dir.pwd unless $:.include?(Dir.pwd)
  end

  after :each do

    @unit.shutdown
  end

  describe 'a conf hook' do

    after :each do

      FileUtils.rm('envs/test/lib/hooks/dot.json', force: true)
    end

    it 'is handed the matching messages' do

      require 'unit/hooks/alpha'
        # require here, since this path is outside of envs/test/

      $seen = []

      hooks = [
        { point: 'receive', class: 'AlphaHook' }
      ]

      File.open('envs/test/lib/hooks/dot.json', 'wb') do |f|
        f.puts(Flor.to_djan(hooks, color: false))
      end

      r =
        @unit.launch(%{
          sequence
            noret _
        }, wait: true)

      expect(r['point']).to eq('terminated')

      expect($seen.size).to eq(6)
    end

    it 'may alter a message'
  end
end

