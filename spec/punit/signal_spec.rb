
#
# specifying flor
#
# Tue Dec 20 16:52:02 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'signal' do

    it 'emits a signal' do

      flon = %{
        signal 'close'
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.420

      expect(
        @unit.journal
          .collect { |m| [ m['point'], m['nid'], m['name'] ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        receive:0:
        signal:0:close
        receive::
        terminated::
      ].join("\n"))
    end
  end
end

