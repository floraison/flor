
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

    it 'emits a signal `signal "xxx"`' do

      r = @unit.launch(
        %q{
          signal 'close'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.journal.find { |m| m['point'] == 'end' } }

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
        end::
      ].join("\n"))
    end

    it 'emits a signal `signal name: "xxx"`' do

      r = @unit.launch(
        %q{
          signal name: 'close'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.journal.find { |m| m['point'] == 'end' } }

      expect(
        @unit.journal
          .collect { |m| [ m['point'], m['nid'], m['name'] ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        receive:0:
        signal:0:close
        receive::
        terminated::
        end::
      ].join("\n"))
    end

    it 'emits signals that have payloads' do

      r = @unit.launch(
        %q{
          set f.a 'A'
          signal 'close'
            set f.b 'B'
            [ 0 1 2 ]
          set f.c 'C'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.journal.find { |m| m['point'] == 'end' } }

      m = @unit.journal.find { |m| m['point'] == 'signal' }

      expect(
        m['payload']
      ).to eq({
        'ret' => [ 0, 1, 2 ], 'a' => 'A', 'b' => 'B'
      })
    end
  end
end

