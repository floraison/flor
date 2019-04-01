
#
# specifying flor
#
# Thu Feb 28 08:55:58 JST 2019
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_c_for_each'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'c-for-each' do

    it 'executes atts in sequence then children in concurrence' do

      r = @unit.launch(
        %q{
          set l []
          c-for-each [ 1 2 3 ]
            def x \ push l (* x 2)
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 1, 2, 3 ])
      expect(r['vars']['l']).to eq([ 2, 4, 6 ])
    end

    it 'shows the index via the "idx" var' do

      r = @unit.launch(
        %q{
          set l []
          c-for-each [ 10 11 12 ]
            def x \ push l [ idx x ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11, 12 ])
    end

    it 'passes the index as second function arg if possible' do

      r = @unit.launch(
        %q{
          set l []
          c-for-each [ 10 11 12 ]
            def x i \ push l [ i x ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 0, 10 ], [ 1, 11 ], [ 2, 12 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11, 12 ])
    end

    it 'passes the length as third function arg if possible' do

      r = @unit.launch(
        %q{
          set a []
          c-for-each [ 10 11 12 ]
            def x i l \ push a [ i l x ]
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ [ 0, 3, 10 ], [ 1, 3, 11 ], [ 2, 3, 12 ] ])
      expect(r['payload']['ret']).to eq([ 10, 11, 12 ])
    end

    it 'iterates over objects' do

      r = @unit.launch(
        %q{
          set l []
          c-for-each { name: 'joe' age: 45 drink: 'coffee' }
            def key, val, idx, len
              push l "$(key):$(val):$(idx):$(len)"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['l']
      ).to eq([
        'name:joe:0:3', 'age:45:1:3', 'drink:coffee:2:3'
      ])
      expect(
        r['payload']['ret']
      ).to eq({
        'name' => 'joe', 'age' => 45, 'drink' => 'coffee'
      })
    end

    it 'iterates over objects (and sets vars)' do

      r = @unit.launch(
        %q{
          set a []
          c-for-each { name: 'joe' age: 45 drink: 'coffee' }
            def k, v, i, l
              push a "$(k):$(v):$(i):$(l)"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['a']
      ).to eq([
        'name:joe:0:3',
        'age:45:1:3',
        'drink:coffee:2:3',
      ])
      expect(
        r['payload']['ret']
      ).to eq({
        'name' => 'joe', 'age' => 45, 'drink' => 'coffee'
      })
    end

    it 'iterates over the incoming f.ret (array)' do

      r = @unit.launch(
        %q{
          set a []
          [ 0 1 2 3 4 5 6 ]
          c-for-each
            def e, i, l \ push a "$(e):$(i):$(l)"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['a']
      ).to eq(%w[
        0:0:7 1:1:7 2:2:7 3:3:7 4:4:7 5:5:7 6:6:7
      ])
      expect(
        r['payload']['ret']
      ).to eq([
        0, 1, 2, 3, 4, 5, 6
      ])
    end

    it 'iterates over the incoming f.ret (object)' do

      r = @unit.launch(
        %q{
          set a []
          { name: 'joe' age: 45 drink: 'coffee' }
          c-for-each
            def k, v, i, l \ push a "$(k):$(v):$(i):$(l)"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['a']
      ).to eq([
        'name:joe:0:3', 'age:45:1:3', 'drink:coffee:2:3'
      ])
      expect(
        r['payload']['ret']
      ).to eq({
        'name' => 'joe', 'age' => 45, 'drink' => 'coffee'
      })
    end

    it 'iterates over the child collection (object)' do

      r = @unit.launch(
        %q{
          set a []
          c-for-each
            { name: 'Jocko' age: 45 drink: 'tea' }
            def k, v, i, l \ push a "$(k):$(v):$(i):$(l)"
        },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['vars']['a']
      ).to eq([
        'name:Jocko:0:3', 'age:45:1:3', 'drink:tea:2:3'
      ])
      expect(
        r['payload']['ret']
      ).to eq({
        'name' => 'Jocko', 'age' => 45, 'drink' => 'tea'
      })
    end

    it 'fails if it is not given a collection' do

      r = @unit.launch(
        %q{
          1
          c-for-each
            def k v i \ [ i k v ]
        },
        wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('collection not given to "c-for-each"')
    end

    it 'returns the collection if it is not given a function' do

      r = @unit.launch(
        %q{
          [ 0 1 2 3 ]
          c-for-each _
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 0, 1, 2, 3 ])
    end

    it 'does not mind attributes and non-coll, non-fun children' do

      r = @unit.launch(
        %q{
          set a []
          [ 0 1 2 3 ]
          c-for-each [ 0 1 2 ]
            "and so it goes"
            def elt \ push a (+ elt 3)
            true
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq([ 3, 4, 5 ])
      expect(r['payload']['ret']).to eq([ 0, 1, 2 ])
    end

    it 'ignores "c_each" custom keys' do

      r = @unit.launch(
        %q{
          c-for-each [ 'a' 'b' ] f.elt
            def elt idx
              push l [ elt idx ]
        },
        vars: { l: [] },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['vars']['l']).to eq([ [ 'a', 0 ], [ 'b', 1 ] ])
      expect(r['payload']['ret']).to eq(%w[ a b ])
    end
  end
end


