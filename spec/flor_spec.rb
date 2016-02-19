
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
        'list' => []
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
{ type: car, make/brand: mitsubishi, id: 2, ok: true, "suppliers,": [], stuff: nada, "'branding'": fail, x: "4", list: [] }
      }.strip)
    end

    it 'returns a compact form when compact: true' do

      expect(
        Flor.to_djan(@v, compact: true)
      ).to eq(%{
{type:car,make/brand:mitsubishi,id:2,ok:true,"suppliers,":[],stuff:nada,"'branding'":fail,x:"4",list:[]}
      }.strip)
    end
  end
end

__END__
  describe "fdja_to_djan()"
  {
    it "quotes symbols that could be mistaken for numbers"
    {
      v = fdja_s("1234.456");

      expect(fdja_to_djan(v, 0) ===f "\"1234.456\"");
    }
  }

  describe "fdja_to_djan() FDJA_F_ONELINE"
  {
    it "turns a fdja_value to a djan string"
    {
      v = fdja_v(
        "{"
          "type: car, "
          "\"make/brand\": mitsubishi, "
          "id: 2, "
          "ok: true"
          "\"suppliers,\": [ ]"
          "stuff: nada"
          "'branding': fail,"
          "x: \"4\""
          "list: []"
        "}"
      );

      expect(v != NULL);

      expect(fdja_to_djan(v, FDJA_F_ONELINE) ===f ""
        "{ "
          "type: car, "
          "make/brand: mitsubishi, "
          "id: 2, "
          "ok: true, "
          "\"suppliers,\": [], "
          "stuff: nada, "
          "branding: fail, "
          "x: \"4\", "
          "list: []"
        " }"
      );
    }

    it "doesn't print the key when the entry is on its own"
    {
      v = fdja_v("{ type: car, make: mitsubishi, id: 2 }");
      fdja_value *vv = fdja_lookup(v, "type");

      expect(fdja_to_djan(vv, FDJA_F_ONELINE) ===f "car");
    }
  }

  describe "fdja_to_djan() FDJA_F_COMPACT"
  {
    it "doesn't print unnecessary spaces"
    {
      v = fdja_v(
        "{"
          "type: car, "
          "\"make/brand\": mitsubishi, "
          "id: 3, "
          "ok: true"
          "\"suppliers,\": [ ]"
          "stuff: nada"
          "'branding': fail,"
          "x: \"4\""
          "list: []"
        "}"
      );

      expect(v != NULL);

      expect(fdja_to_djan(v, FDJA_F_COMPACT) ===f ""
        "{"
          "type:car,"
          "make/brand:mitsubishi,"
          "id:3,"
          "ok:true,"
          "\"suppliers,\":[],"
          "stuff:nada,"
          "branding:fail,"
          "x:\"4\","
          "list:[]"
        "}"
      );
    }

    it "doesn't print the key when the entry is on its own"
    {
      v = fdja_v("{ type: car, make: mitsubishi, id: 2 }");
      fdja_value *vv = fdja_lookup(v, "type");

      expect(fdja_to_djan(vv, FDJA_F_ONELINE) ===f "car");
    }
  }

  describe "fdja_to_djan() FDJA_F_OBJ"
  {
    it "doesn't output the top {} obj brackets (single line)"
    {
      v = fdja_v(
        "{"
          "type: car\n"
          "\"make/brand\": mitsubishi\n"
          "id: 3\n"
        "}"
      );

      expect(v != NULL);

      expect(fdja_to_djan(v, FDJA_F_OBJ) ===f ""
        "type: car, make/brand: mitsubishi, id: 3"
      );
    }

    it "doesn't output the top {} obj brackets"
    {
      v = fdja_v(
        "{"
          "type: car\n"
          "\"make/brand\": mitsubishi\n"
          "id: 3\n"
          "ok: true\n"
          "\"suppliers,\": [ ]\n"
          "stuff: nada\n"
          "'branding': fail\n"
          "x: \"4\"\n"
          "list: []"
        "}"
      );

      expect(v != NULL);

      expect(fdja_to_djan(v, FDJA_F_OBJ) ===f ""
        "type: car\n"
        "make/brand: mitsubishi\n"
        "id: 3\n"
        "ok: true\n"
        "\"suppliers,\": []\n"
        "stuff: nada\n"
        "branding: fail\n"
        "x: \"4\"\n"
        "list: []\n"
      );
    }
  }

  describe "fdja_to_djan() multiline"
  {
    it "turns a fdja_value to a pretty djan string"
    {
      v = fdja_v(
        "{"
          "type: car, "
          "\"make\\/brand\": mitsubishi, "
          "id: 2, "
          "ok: true"
          "\"suppliers,\": [ alpha, bravo, charly, \"4\", 3 ]"
          "list: []"
          "stuff: nada"
          "'branding': fail "
          "0: ok"
        "}"
      );

      expect(v != NULL);

      //flu_putf(fdja_to_djan(v, 0));
      expect(fdja_to_djan(v, 0) ===f ""
        "{\n"
        "  type: car\n"
        "  \"make\\/brand\": mitsubishi\n"
        "  id: 2\n"
        "  ok: true\n"
        "  \"suppliers,\": [ alpha, bravo, charly, \"4\", 3 ]\n"
        "  list: []\n"
        "  stuff: nada\n"
        "  branding: fail\n"
        "  0: ok\n"
        "}"
      );
    }
  }

