
#
# specifying flor
#
# Mon May 23 10:54:18 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'trace' do

    it 'traces' do

      flor = %{
        trace 'hello'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })

      traces = @unit.traces.all

      expect(traces.count).to eq(1)
      expect(traces[0].exid).to eq(r['exid'])
      expect(traces[0].nid).to eq('0')
      expect(traces[0].tracer).to eq('trace')
      expect(traces[0].text).to eq('hello')
    end

    it 'traces in sequence' do

      flor = %{
        sequence
          trace 'a'
          set x 0
          trace 'b'
          set x 1
          trace 'c'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => nil })

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b c'
      )
    end

    it "doesn't mind tag:" do

      flor = %q{
        trap tag: 'x'
          def msg \ trace "$(msg.point):x"
        trace 'a', tag: 'x'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_func', { 'nid' => '0_0_1', 'cnid' => '0_0', 'fun' => 0 }, 3 ]
      )

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a entered:x'
      )
    end

    it 'traces multiple times' do

      @unit.hooker.add('journal', Flor::Journal)

      flor = %{
        trace 'a', 'b', tag: 'x', 'c'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b c'
      )

      expect(
        @unit.journal
          .reject { |m| m['point'] == 'end' }
          .collect { |m|
            tags = m['tags']; tags = tags ? tags.join(',') : nil
            [ m['nid'], m['point'], tags ].compact.join(':') }
          .join("\n")
      ).to eq(%w[
        0:execute
        0_0:execute
        0_0_0:execute
        0_0:receive
        0:receive
        0_1:execute
        0_1_0:execute
        0_1:receive
        0:receive
        0_2:execute
        0_2_0:execute
        0_2:receive
        0_2_1:execute
        0_2:receive
        0:entered:x
        0:receive
        0_3:execute
        0_3_0:execute
        0_3:receive
        0:receive
        receive
        0:left:x
        terminated
      ].join("\n"))
    end

    it "doesn't touch f.ret" do

      flor = %{
        123
        trace 'a'
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(123)
    end
  end
end

