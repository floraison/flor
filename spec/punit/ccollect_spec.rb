
#
# specifying flor
#
# Wed Nov  8 09:44:49 JST 2017  Asia Square
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

  describe 'ccollect' do

    it 'executes atts in sequence then children in concurrence' do

      r = @unit.launch(
        %q{
          ccollect [ 1 2 3 ]
            * elt 2
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
          ccollect [ 10 11 12 ]
            [ idx elt ]
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
    end

    it 'preserves the children order' do

      r = @unit.launch(
        %q{
          ccollect [ 1 2 3 ]
            sleep 0.4 if (elt % 2) == 0
            elt
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 3 ])
    end
  end
end


