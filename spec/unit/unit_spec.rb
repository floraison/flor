
#
# specifying flor
#
# Tue Jan 31 14:41:20 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'unit_unit'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'Flor::Unit' do

    it 'launches 3 flows in a row' do

      exids = []

      3.times do |i|

        exids <<
          @unit.launch(%{
            sequence
              sequence
               sequence
                 sequence
                   sequence
                    sequence
                      stall _
          },
          vars: { flid: i })
      end

      expect(exids.size).to eq(3)

      @unit.wait(exids.last, '0_0_0_0_0_0_0 receive')
    end
  end
end

