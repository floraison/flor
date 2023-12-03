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
          "already \" escaped"
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

    it 'is ok with string keys' do

      d =
        { "0":       { user_id: 0, aum: 0, pitch_aum: 0, review_aum: 0, Pitch: 3, Others: 1, Social: 1, Review: 2 },
          "313327975":{ user_id: 313327975, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Pitch: 1, Review: 1 },
          "837":     { user_id: 837, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Pitch: 1 },
          "899":     { user_id: 899, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Others: 1, Social: 1, Pitch: 1, Review: 1 } }

      expect(
        Flor.to_djan(d, indent: 2, width: true, colours: false)
      ).to eq('  ' + %{
  { "0":         { user_id: 0, aum: 0, pitch_aum: 0, review_aum: 0, Pitch: 3, Others: 1, Social: 1, Review: 2 },
    "313327975": { user_id: 313327975, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Pitch: 1, Review: 1 },
    "837":       { user_id: 837, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Pitch: 1 },
    "899":       { user_id: 899, aum: 0, pitch_aum: 0, review_aum: 0, items: [], Others: 1, Social: 1, Pitch: 1, Review: 1 } }
      }.strip)
    end
  end
end

