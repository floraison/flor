
#
# specifying flor
#
# Thu Feb 16 21:47:27 JST 2017
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'graftest'
    #@unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'graft' do

    it 'fails if it cannot find the subtree' do

      r = @unit.launch(
        %q{
          graft 'sub99'
        },
        wait: true)

      expect(r['point']).to eq(
        'failed')
      expect(r['error']['msg']).to eq(
        'no subtree "sub99" found (domain "test")')
    end

    it 'grafts a subtree in the current tree' do

      r = @unit.launch(
        %q{
          sequence
            set a []
            graft 'sub0'
            graft 'sub0'
        },
        domain: 'com.acme.alpha',
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ 1, 1 ])
    end

    it 'grafts a subtree with function definitions' do

      r = @unit.launch(
        %q{
          set a []
          graft 'sub1_funs'
          stack 1
          stack 2
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ 1, 2 ])
    end

    it 'accepts the file suffix in the graft name' do

      r = @unit.launch(
        %q{
          sequence
            set a []
            graft 'sub0'
            graft 'sub0.flo'
        },
        domain: 'com.acme.alpha',
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ 1, 1 ])
    end

    it 'is ok grafting at the root' do

      r = @unit.launch(
        %q{
          #graft 'sub0'
          import 'sub0'
        },
        domain: 'com.acme.alpha',
        vars: { 'a' => [] },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ 1 ])
    end
  end
end

