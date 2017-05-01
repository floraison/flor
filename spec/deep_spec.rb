
#
# specifying flor
#
# Tue Mar  1 07:05:16 JST 2016
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
      [ :@cars, 'simca', nil ],
      [ :@cars, 'alpha', { 'id' => 'FR1' } ],
      [ :@cars, 'alpha.id', 'FR1' ],

      [ :@cars, 'bentley.1', 'spur' ],
      [ :@cars, 'bentley.other', 'bentley.other'.to_sym ],
      [ :@cars, 'bentley.other.nada', 'bentley.other'.to_sym ],

      [ :@cars, 'bentley[1]', 'spur' ],
      [ :@cars, 'bentley["other"]', 'bentley.other'.to_sym ],
      [ :@cars, "bentley.other['nada']", 'bentley.other'.to_sym ],

      [ :@ranking, '0', 'Anh' ],
      [ :@ranking, '1', 'Bob' ],
      [ :@ranking, '-1', 'Charly' ],
      [ :@ranking, '-2', 'Bob' ],
      [ :@ranking, 'first', 'Anh' ],
      [ :@ranking, 'last', 'Charly' ]

    ].each do |o, k, v|

      it "gets #{k.inspect}" do

        o = self.instance_eval(o.to_s)

        expect(Flor.deep_get(o, k)).to eq(v)
      end
    end
  end

  describe '.deep_set' do

    it 'sets at the first level' do

      o = {}
      r = Flor.deep_set(o, 'a', 1)

      expect(o).to eq({ 'a' => 1 })
      expect(r).to eq(1)
    end

    it 'sets at the second level in a hash' do

      o = { 'h' => {} }
      r = Flor.deep_set(o, 'h.i', 1)

      expect(o).to eq({ 'h' => { 'i' => 1 } })
      expect(r).to eq(1)
    end

    it 'sets at the second level in an array ' do

      o = { 'a' => [ 1, 2, 3 ] }
      r = Flor.deep_set(o, 'a.1', 1)

      expect(o).to eq({ 'a' => [ 1, 1, 3 ] })
      expect(r).to eq(1)
    end

    it 'sets array first' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Flor.deep_set(o, 'h.a.first', 'one')

      expect(o).to eq({ 'h' => { 'a' => [ "one", 2, 3 ] } })
      expect(r).to eq('one')
    end

    it 'sets array last' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Flor.deep_set(o, 'h.a.last', 'three')

      expect(o).to eq({ 'h' => { 'a' => [ 1, 2, 'three' ] } })
      expect(r).to eq('three')
    end

    it 'returns false if it cannot set' do

      c = {}
      r = Flor.deep_set(c, 'a.b', 1)
      expect(c).to eq({})
      expect(r).to eq(:a)

      c = []
      r = Flor.deep_set(c, 'a', 1)
      expect(c).to eq([])
      expect(r).to eq(:'')
    end
  end

  describe '.deep_unset' do

    it 'unsets at the first level' do

      o = { 'a' => 1 }
      r = Flor.deep_unset(o, 'a')

      expect(o).to eq({})
      expect(r).to eq(1)
    end

    it 'unsets at the second level in a hash' do

      o = { 'h' => { 'i' => 1 } }
      r = Flor.deep_unset(o, 'h.i')

      expect(o).to eq({ 'h' => {} })
      expect(r).to eq(1)
    end

    it 'unsets at the second level in an array ' do

      o = { 'a' => [ 1, 2, 3 ] }
      r = Flor.deep_unset(o, 'a.1')

      expect(o).to eq({ 'a' => [ 1, 3 ] })
      expect(r).to eq(2)
    end

    it 'unsets array first' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Flor.deep_unset(o, 'h.a.first')

      expect(o).to eq({ 'h' => { 'a' => [ 2, 3 ] } })
      expect(r).to eq(1)
    end

    it 'unsets array last' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Flor.deep_unset(o, 'h.a.last')

      expect(o).to eq({ 'h' => { 'a' => [ 1, 2 ] } })
      expect(r).to eq(3)
    end

    it 'returns false if it cannot unset' do

      c = {}
      r = Flor.deep_unset(c, 'a.b')
      expect(c).to eq({})
      expect(r).to eq(:a)

      c = []
      r = Flor.deep_unset(c, 'a')
      expect(c).to eq([])
      expect(r).to eq(:'')
    end
  end

  describe '.deep_insert' do

    it 'inserts at the first level' do

      o = {}
      r = Flor.deep_insert(o, 'a', 1)

      expect(o).to eq({ 'a' => 1 })
      expect(r).to eq(1)
    end

    it 'inserts at the second level in a hash' do

      o = { 'h' => {} }
      r = Flor.deep_insert(o, 'h.i', 1)

      expect(o).to eq({ 'h' => { 'i' => 1 } })
      expect(r).to eq(1)
    end

    it 'inserts at the second level in an array ' do

      o = { 'a' => [ 1, 2, 3 ] }
      r = Flor.deep_insert(o, 'a.1', 1)

      expect(o).to eq({ 'a' => [ 1, 1, 2, 3 ] })
      expect(r).to eq(1)
    end

    it 'inserts as array first' do

      o = { 'a' => [ 'one', [ 2, 3, 4 ], 'three' ] }
      r = Flor.deep_insert(o, 'a.1.first', 1)

      expect(o).to eq({ 'a' => [ 'one', [ 1, 2, 3, 4 ], 'three' ] })
      expect(r).to eq(1)
    end

    it 'inserts as array last' do

      o = { 'a' => [ 'one', [ 2, 3, 4 ], 'three' ] }
      r = Flor.deep_insert(o, 'a.1.last', 5)

      expect(o).to eq({ 'a' => [ 'one', [ 2, 3, 4, 5 ], 'three' ] })
      expect(r).to eq(5)
    end

    it 'returns false if it cannot set' do

      c = {}
      r = Flor.deep_insert(c, 'a.b', 1)
      expect(c).to eq({})
      expect(r).to eq(:a)

      c = []
      r = Flor.deep_insert(c, 'a', 1)
      expect(c).to eq([])
      expect(r).to eq(:'')
    end
  end

  describe '.deep_has_key?' do

#@cars = {
#  'alpha' => { 'id' => 'FR1' },
#  'bentley' => %w[ blower spur markv ]
#}
#@ranking = %w[ Anh Bob Charly ]
    it 'works' do

      expect(Flor.deep_has_key?(@cars, 'nada')).to eq(false)
      expect(Flor.deep_has_key?(@cars, 'alpha.nada')).to eq(false)
      expect(Flor.deep_has_key?(@cars, 'bentley.nada')).to eq(false)
      expect(Flor.deep_has_key?(@cars, 'bentley.3')).to eq(false)
      expect(Flor.deep_has_key?(@cars, 'bentley.-4')).to eq(false)

      expect(Flor.deep_has_key?(@cars, 'alpha')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'alpha.id')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'bentley')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'bentley.0')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'bentley.-1')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'bentley.first')).to eq(true)
      expect(Flor.deep_has_key?(@cars, 'bentley.last')).to eq(true)
    end
  end
end

