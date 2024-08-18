
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
    #@unit.hooker.add('journal', Flor::Journal)
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

    it 'accepts custom keys (arrays)' do

      r = @unit.launch(
        %q{
          set l []
          ceach [ 10 11 ] f.elt v.idx
            push l [ idx f.elt ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, 10 ], [ 1, 11 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11 ])
    end

    it 'accepts custom keys (arrays) (2)' do

      r = @unit.launch(
        %q{
          set l []
          c-each [ 'lab a', 'lab b' ] v.lab
            push l lab
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ 'lab a', 'lab b' ])
    end

    it 'accepts custom keys (objects)' do

      r = @unit.launch(
        %q{
          set l []
          ceach { a: 'A' b: 'B' } f.k f.v v.i
            push l [ i [ f.k, f.v ] ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, [ 'a', 'A' ] ], [ 1, [ 'b', 'B' ] ] ])
      expect(r['payload']['ret']).to eq({ 'a' => 'A', 'b' => 'B' })
    end

    it 'accepts expect: and remaining:' do

      r = @unit.launch(
        %q{
          set l []
          c-each [ 0 1 2 ] expect: 1 remaining: 'cancel'
            sleep for: "$(elt)s"
            push l (* elt 2)
        },
        wait: true)

      expect(r['vars']['l']).to eq([ 0 ])
    end

    it 'accepts expect: and remaining: (2)' do

      r = @unit.launch(
        %q{
          set l []
          set labs [ 'lab alpha', 'lab biometa', 'lab cruz' ]

          #c-each labs v.lab expect: 2 remaining: 'cancel'
          #  push l lab
          c-each labs expect: 2 remaining: 'cancel'
            sleep for: "$(idx)s"
            push l elt
        },
        wait: true)

      expect(r['vars']['l']).to eq([ 'lab alpha', 'lab biometa' ])
    end

    it 'accepts expect: and remaining: (3)' do

      r = @unit.launch(
        %q{
          set l []
          set labs [ 'lab arcturus', 'lab brizer', 'lab cruz' ]

          c-each labs v.lab expect: 2 remaining: 'cancel'
            sleep for: "$(idx)s"
            push l lab
        },
        wait: true)
pp r

      #expect(r['point']).to eq('terminated')
      #expect(r['vars']['l']).to eq([ 'lab arcturus', 'lab brizer' ])
# FIXME TODO
    end
  end
end


