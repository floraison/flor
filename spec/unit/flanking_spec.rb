# encoding: UTF-8

#
# specifying flor
#
# Tue Mar 28 07:40:11 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'uflanking'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'flanking' do

    it 'flanks burgers' do

      flor = %{
        sequence
          sequence flank
            stall _
          sequence _
          stall _
      }

      ms = @unit.launch(flor, wait: '0_2 receive')

      exe = @unit.executions[exid: ms['exid']].data
#pp exe
    end
  end
end

