
#
# specifying flor
#
# Sat Mar  4 07:50:19 JST 2017  Koi naka
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = '_arr_as_pu'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe '_arr' do

    it 'considers its attributes first' #do
#
#      flor = %{
#        [
#          (sleep '5s')
#          1
#          2
#        ] timeout: '2h'
#      }
#
#      r = @unit.launch(flor)
#
#      sleep 0.490
#
#      expect(@unit.timers.collect(&:schedule)).to eq(%w[ 2h 5s ])
#    end
  end
end

