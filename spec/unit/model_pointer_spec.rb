
#
# specifying flor
#
# Sat Mar  9 07:23:36 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'mpointer'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  context 'models' do

    describe 'Flor::Pointer model' do

      it 'points to a task' do

        exid =
          @unit.launch(
            %q{
              bravo 'do the job'
            })

        pointer = wait_until {
          @unit.pointers.where(exid: exid, type: 'tasker').first }

        expect(pointer.unit).to eq(@unit)
        expect(pointer.storage).to eq(@unit.storage)

        expect(pointer.execution.exid).to eq(exid)
        expect(pointer.execution.status).to eq('active')

        expect(pointer.node['nid']
          ).to eq('0')
        expect(pointer.node['task']
          ).to eq('tasker' => 'bravo', 'name' => 'do the job')

        expect(pointer.fei).to eq("#{exid}-0")
      end
    end
  end
end

