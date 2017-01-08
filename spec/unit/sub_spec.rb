
#
# specifying flor
#
# Mon Jan  9 07:54:05 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u_sub'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'flor' do

    it 'uses unique subids' do

      r =
        @unit.launch(%{
          cmap [ 1 2 ]
            def i
              cmap [ 'x' 'y' ]
                def c
                  trace "$(i):$(c)"
        }, wait: true)

      expect(r['point']).to eq('terminated')

      sleep 0.210

      expect(
        @unit.traces
          .collect { |t| t.text }.sort.join("\n")
      ).to eq(%w[
        1:x 1:y 2:x 2:y
      ].join("\n"))

      exe = @unit.executions[exid: r['exid']]

      expect(exe.data['counters']['subs']).to eq(6)

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'execute' && m['nid'].index('-') }
          .inject({}) { |h, m|
            si = m['nid'].split('-').last; h[si] ||= m; h }.values
          .collect { |m|
            [ m['nid'], m['point'], 'L' + m['tree'][2].to_s ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_1-1:execute:L2
        0_1-2:execute:L2
        0_1_1_1-3:execute:L4
        0_1_1_1-4:execute:L4
        0_1_1_1-5:execute:L4
        0_1_1_1-6:execute:L4
      ].join("\n"))
    end
  end
end

