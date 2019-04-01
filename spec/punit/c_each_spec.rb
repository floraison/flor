
#
# specifying flor
#
# Thu Feb 28 12:30:34 JST 2019
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

  describe 'ceach / c-each' do

    it 'executes atts in sequence then children in concurrence' do

      r = @unit.launch(
        %q{
          set l []
          c-each [ 1 2 3 ]
            push l (* elt 2)
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ 2, 4, 6 ])
      expect(r['payload']['ret']).to eq([ 1, 2, 3 ])
    end

    it 'shows the index via the "idx" var' do

      r = @unit.launch(
        %q{
          set l []
          ceach [ 10 11 12 ]
            push l [ idx elt ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11, 12 ])
    end

    it 'accepts custom keys' do

      r = @unit.launch(
        %q{
          set l []
          ceach [ 10 11 ] f.elt f.idx
            push l [ f.idx f.elt ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, 10 ], [ 1, 11 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11 ])
    end
  end
end


