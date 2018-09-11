
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

      r = @unit.launch(
        %q{
          cmap _
        }, wait: true)

      expect(r['point']).to eq('terminated')
    end

    it 'has no effect when empty (2)' do

      r = @unit.launch(
        %q{
          cmap tag: 'z'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      wait_until { @unit.journal.find { |m| m['point'] == 'left' } }

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

      r = @unit.launch(
        %q{
          cmap [ 1 2 3 ]
            def x \ * x 2
        },
        wait: true)

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

    it 'shows the index via the "idx" var' do

      r = @unit.launch(
        %q{
          cmap [ 10 11 12 ]
            def x \ [ idx x ]
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
    end

    it 'passes the index as second function arg if possible' do

      r = @unit.launch(
        %q{
          cmap [ 10 11 12 ]
            def x i \ [ i x ]
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
    end

    it 'passes the length as third function arg if possible' do

      r = @unit.launch(
        %q{
          cmap [ 10 11 12 ]
            def x i l \ [ i l x ]
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq([
        [ 0, 3, 10 ], [ 1, 3, 11 ], [ 2, 3, 12 ]
      ])
    end

    it 'preserves the children order' do

      r = @unit.launch(
        %q{
          cmap [ 1 2 3 ]
            def x
              sleep 0.4 if (x % 2) == 0
              x
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 3 ])
    end
  end
end


