
#
# specifying flor
#
# Sun Jan  8 06:19:45 JST 2017  Ishinomaki
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_cmap'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'cmap' do

    it 'has no effect when empty' do

      flor = %{
        cmap _
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')
    end

    it 'has no effect when empty (2)' do

      flor = %{
        cmap tag: 'z'
      }

      msg = @unit.launch(flor, wait: true)

      expect(msg['point']).to eq('terminated')

      sleep 0.4 # for jruby

      expect(
        @unit.journal
          .select { |m|
            %w[ entered left ].include?(m['point']) }
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        entered:0:z
        left:0:z
      ].join("\n"))
    end

    it 'executes atts in sequence then children in concurrence' do

      flor = %{
        cmap [ 1 2 3 ]
          def x; (* x 2)
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq([ 2, 4, 6 ])

      #expect(
      #  @unit.journal
      #    .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
      #).to comprise(%w[
      #  exe:0_2 exe:0_3
      #  exe:0_2_0 exe:0_3_0
      #  exe:0_2_0_0 exe:0_3_0_0
      #])
    end
  end
end


