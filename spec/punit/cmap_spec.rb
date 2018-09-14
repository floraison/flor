
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

    it 'iterates over objects' do

      r = @unit.launch(
        %q{
          cmap { name: 'joe' age: 45 drink: 'coffee' }
            def key, val, idx, len
              "$(key):$(val):$(idx):$(len)"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq([
        'name:joe:0:3', 'age:45:1:3', 'drink:coffee:2:3'
      ])
    end

    it 'iterates over objects (and sets vars)' do

      r = @unit.launch(
        %q{
          cmap { name: 'joe' age: 45 drink: 'coffee' }
            def k, v, i, l
              "$(k):$(v):$(i):$(l)/$(key):$(val):$(idx):$(len)"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq([
        'name:joe:0:3/name:joe:0:3',
        'age:45:1:3/age:45:1:3',
        'drink:coffee:2:3/drink:coffee:2:3'
      ])
    end

    it 'iterates over the incoming f.ret (array)' do

      r = @unit.launch(
        %q{
          [ 0 1 2 3 4 5 6 ]
          cmap
            def e, i, l \ "$(e):$(i):$(l)"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(%w[
        0:0:7 1:1:7 2:2:7 3:3:7 4:4:7 5:5:7 6:6:7
      ])
    end

    it 'iterates over the incoming f.ret (object)' do

      r = @unit.launch(
        %q{
          { name: 'joe' age: 45 drink: 'coffee' }
          cmap
            def k, v, i, l \ "$(k):$(v):$(i):$(l)"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq([
        'name:joe:0:3', 'age:45:1:3', 'drink:coffee:2:3'
      ])
    end

    it 'iterates over the child collection (object)' do

      r = @unit.launch(
        %q{
          cmap
            { name: 'Jocko' age: 45 drink: 'tea' }
            def k, v, i, l \ "$(k):$(v):$(i):$(l)"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq([
        'name:Jocko:0:3', 'age:45:1:3', 'drink:tea:2:3'
      ])
    end

    it 'fails if it is not given a collection' do

      r = @unit.launch(
        %q{
          1
          cmap
            def k v i \ [ i k v ]
        },
        wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('collection not given to "cmap"')
    end

    it 'returns the collection if it is not given a function' do

      r = @unit.launch(
        %q{
          [ 0 1 2 3 ]
          cmap _
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 1, 2, 3 ])
    end
  end
end


