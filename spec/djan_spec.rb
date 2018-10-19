# encoding: UTF-8

#
# specifying flor
#
# Sun Feb  7 14:27:04 JST 2016
#

require 'spec_helper'


describe Flor do

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
        'dict' => {},
        'date' => '2017-03-13',
        'exp' => 'a+b'
      }
    end

    it 'quotes symbols that could be mistaken for numbers' do

      expect(Flor.to_djan('123', colours: false)).to eq('"123"')
      expect(Flor.to_djan('123.456', colours: false)).to eq('"123.456"')
    end

    it 'turns an object into a djan string' do

      expect(
        Flor.to_djan(@v, colours: false)
      ).to eq(%{
{ type: car, "make/brand": mitsubishi, id: 2, ok: true, "suppliers,": [], stuff: nada, "'branding'": fail, x: "4", list: [], dict: {}, date: "2017-03-13", exp: "a+b" }
      }.strip)
    end

    it 'returns a compact form when compact: true' do

      expect(
        Flor.to_djan(@v, compact: true, colours: false)
      ).to eq(%{
{type:car,"make/brand":mitsubishi,id:2,ok:true,"suppliers,":[],stuff:nada,"'branding'":fail,x:"4",list:[],dict:{},date:"2017-03-13",exp:"a+b"}
      }.strip)
    end

    it 'respects width: 80' do

      expect(
        Flor.to_djan(@v, width: 80, colours: false)
      ).to eq(%{
{ type:         car,
  "make/brand": mitsubishi,
  id:           2,
  ok:           true,
  "suppliers,": [],
  stuff:        nada,
  "'branding'": fail,
  x:            "4",
  list:         [],
  dict:         {},
  date:         "2017-03-13",
  exp:          "a+b" }
      }.strip)
    end

    it 'respects json: true' do

      expect(
        Flor.to_djan(@v, json: true, colours: false)
      ).to eq(%{
{ "type": "car", "make/brand": "mitsubishi", "id": 2, "ok": true, "suppliers,": [], "stuff": "nada", "'branding'": "fail", "x": "4", "list": [], "dict": {}, "date": "2017-03-13", "exp": "a+b" }
      }.strip)
    end

    it 'respects width: 80 (take 2)' do

      v = {
        'type' => 'car',
        'make/brand' => 'mitsubishi',
        'id' => 2,
        'ok' => true,
        'suppliers,' => [
          'alfred',
          { 'bob' => 'the builder', 'charles' => 'the over builder' },
          { 'dick' => 'd' * 20, 'eric' => 'e' * 30, 'faye' => 'f' * 40 },
          [ 0, 1, 2, 3, 4 ],
          true,
          false,
          12345.67,
          "the long chemin est un chemin d'automne au travers de l'île",
          'this is a "double-quote"',
          'already \" escaped'
        ],
        'stuff' => 'nada',
        "'branding'" => 'fail',
        'x' => '4',
        'list' => [],
        'dict' => {},
        'date' => '2017-03-13',
        'exp' => 'a+b'
      }

      expect(
        Flor.to_d(v, colours: false, json: true, width: 80, indent: 0)
      ).to eq(%q{
{ "type":
    "car",
  "make/brand":
    "mitsubishi",
  "id":
    2,
  "ok":
    true,
  "suppliers,":
    [ "alfred",
      { "bob": "the builder", "charles": "the over builder" },
      { "dick": "dddddddddddddddddddd",
        "eric": "eeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
        "faye": "ffffffffffffffffffffffffffffffffffffffff" },
      [ 0, 1, 2, 3, 4 ],
      true,
      false,
      12345.67,
      "the long chemin est un chemin d'automne au travers de l'île",
      "this is a \"double-quote\"",
      "already \" escaped" ],
  "stuff":
    "nada",
  "'branding'":
    "fail",
  "x":
    "4",
  "list":
    [],
  "dict":
    {},
  "date":
    "2017-03-13",
  "exp":
    "a+b" }
      }.strip)
    end
  end
end

