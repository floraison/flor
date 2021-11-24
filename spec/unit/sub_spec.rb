
#
# specifying flor
#
# Mon Jan  9 07:54:05 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

@flor_debug = ENV['FLOR_DEBUG']
ENV['FLOR_DEBUG'] = 'dbg,stdout'
    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u_sub'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
ENV['FLOR_DEBUG'] = @flor_debug
  end

  describe 'flor' do

    it 'uses unique subids (cmap/cmap)' do

      r =
        @unit.launch(%{
          cmap [ 1 2 ]
            def i
              cmap [ 'x' 'y' ]
                def c
                  trace "$(i):$(c)"
                  "$(i):$(c)"
        }, wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ %w[ 1:x 1:y ], %w[ 2:x 2:y ] ])

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

    it 'uses unique subids (cmap/cursor)' do

      r =
        @unit.launch(%{
          cmap [ 1 2 ]
            def i
              set j 2
              cursor
                trace "$(node.nid):i$(i):j$(j)"
                set j (j - 1)
                continue _ if (> j 0)
        }, wait: 21)

      expect(r).to have_terminated_as_point

      sleep 0.350

      nids_with_subs = @unit.journal
        .select { |m| m['point'] == 'execute' && m['nid'].index('-') }
        .collect { |m| m['nid'] }
        .sort

      expect(
        nids_with_subs
          .join("\n")
      ).to eq(
        nids_with_subs.uniq
          .join("\n")
      )

      expect(
        @unit.traces
          .collect { |t| t.text }.sort.join("\n")
      ).to eq(%w[
        0_1_2_0_0_0_0_0_0-1:i1:j2
        0_1_2_0_0_0_0_0_0-2:i2:j2
        0_1_2_0_0_0_0_0_0-3:i1:j1
        0_1_2_0_0_0_0_0_0-4:i2:j1
      ].join("\n"))
    end
  end
end

