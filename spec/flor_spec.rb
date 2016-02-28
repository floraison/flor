
#
# specifying flor
#
# Sun Feb  7 14:27:04 JST 2016
#

require 'spec_helper'


describe Flor do

  before :each do

    @cars = {
      'alpha' => { 'id' => 'FR1' },
      'bentley' => %w[ blower spur markv ]
    }
    @ranking = %w[ Anh Bob Charly ]
  end

  describe '.deep_get' do

    [
      [ :cars, 'simca', [ true, nil ], __LINE__ ],
      [ :cars, 'alpha', [ true, { 'id' => 'FR1' } ], __LINE__ ],
      [ :cars, 'alpha.id', [ true, 'FR1' ], __LINE__ ],

      [ :cars, 'bentley.1', [ true, 'spur' ], __LINE__ ],
      [ :cars, 'bentley.other', [ false, nil ] ],
      [ :cars, 'bentley.other.nada', [ false, nil ] ],

      [ :ranking, '0', [ true, 'Anh' ], __LINE__ ],
      [ :ranking, '1', [ true, 'Bob' ], __LINE__ ],
      [ :ranking, '-1', [ true, 'Charly' ], __LINE__ ],
      [ :ranking, '-2', [ true, 'Bob' ], __LINE__ ],
      [ :ranking, 'first', [ true, 'Anh' ], __LINE__ ],
      [ :ranking, 'last', [ true, 'Charly' ], __LINE__ ],

    ].each do |o, k, v, l|

      it "gets #{k.inspect} (line #{l})" do

        o = self.instance_eval("@#{o}")

        #if v.is_a?(Class)
        #  expect { Flor.deep_get(o, k) }.to raise_error(v)
        #else
        #  expect(Flor.deep_get(o, k)).to eq(v)
        #end
        expect(Flor.deep_get(o, k)).to eq(v)
      end
    end
  end

  describe '.deep_set' do

    it 'sets at the first level' do

      o = {}
      r = Flor.deep_set(o, 'a', 1)

      expect(o).to eq({ 'a' => 1 })
      expect(r).to eq([ true, 1 ])
    end

    it 'sets at the second level in a hash' do

      o = { 'h' => {} }
      r = Flor.deep_set(o, 'h.i', 1)

      expect(o).to eq({ 'h' => { 'i' => 1 } })
      expect(r).to eq([ true, 1 ])
    end

    it 'sets at the second level in an array ' do

      o = { 'a' => [ 1, 2, 3 ] }
      r = Flor.deep_set(o, 'a.1', 1)

      expect(o).to eq({ 'a' => [ 1, 1, 3 ] })
      expect(r).to eq([ true, 1 ])
    end

    it 'returns false if it cannot set' do

      c = {}
      r = Flor.deep_set(c, 'a.b', 1)
      expect(c).to eq({})
      expect(r).to eq([ false, 1 ])

      c = []
      r = Flor.deep_set(c, 'a', 1)
      expect(c).to eq([])
      expect(r).to eq([ false, 1 ])
    end
  end

  describe '.to_djan' do

    before :each do

      @v = {
        'type' => 'car',
        'make/brand' => 'mitsubishi',
        'id' => 2,
        'ok' => true,
        'suppliers,' => [],
        'stuff' => 'nada',
        "'branding'" => 'fail',
        'x' => '4',
        'list' => [],
        'dict' => {}
      }
    end

    it 'quotes symbols that could be mistaken for numbers' do

      expect(Flor.to_djan('123')).to eq('"123"')
      expect(Flor.to_djan('123.456')).to eq('"123.456"')
    end

    it 'turns an object into a djan string' do

      expect(
        Flor.to_djan(@v)
      ).to eq(%{
{ type: car, make/brand: mitsubishi, id: 2, ok: true, "suppliers,": [], stuff: nada, "'branding'": fail, x: "4", list: [], dict: {} }
      }.strip)
    end

    it 'returns a compact form when compact: true' do

      expect(
        Flor.to_djan(@v, compact: true)
      ).to eq(%{
{type:car,make/brand:mitsubishi,id:2,ok:true,"suppliers,":[],stuff:nada,"'branding'":fail,x:"4",list:[],dict:{}}
      }.strip)
    end
  end

  describe '.next_child_id' do

    it 'works' do

      expect(Flor.next_child_id('0_0')).to eq(1)
      expect(Flor.next_child_id('0_0_9')).to eq(10)
      expect(Flor.next_child_id('0_0_9-3')).to eq(10)
    end
  end

  describe '.parent_id' do

    it 'works' do

      expect(Flor.parent_id('0')).to eq(nil)
      expect(Flor.parent_id('0_1')).to eq('0')
      expect(Flor.parent_id('0_1_9')).to eq('0_1')
      expect(Flor.parent_id('0_1_9-6')).to eq('0_1')
    end
  end

  describe '.child_id' do

    it 'works' do

      expect(Flor.child_id('0')).to eq(0)
      expect(Flor.child_id('0_1')).to eq(1)
      expect(Flor.child_id('0_1_7')).to eq(7)
      expect(Flor.child_id('0_1_9-6')).to eq(9)
    end
  end

  describe '.master_nid' do

    it 'removes the sub_nid' do

      expect(Flor.master_nid('0_7-1')).to eq('0_7')
    end

    it "doesn't remove a missing sub_nid" do

      expect(Flor.master_nid('0_5')).to eq('0_5')
    end
  end

  describe '.is_tree?' do

    it 'returns true when passed a tree' do

      fail
    end

    it 'returns false when passed something other than a tree' do

      fail
    end
  end
end

