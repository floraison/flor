
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

#  describe '.is_tree?' do
#
#    it 'returns true when passed a tree' do
#
#      expect(
#        Flor.is_tree?([ 'val', {}, -1, [] ])
#      ).to eq(true)
#    end
#
#    it 'returns false when passed something other than a tree' do
#
#      expect(
#        Flor.is_tree?([ 'val', {}, true, [] ])
#      ).to eq(false)
#    end
#  end

  describe '.tstamp' do

    it 'returns the current timestamp' do

      expect(Flor.tstamp).to match(/\A#{Time.now.year}\d{4}.\d{12}\z/)
    end

    it 'turns a Time instance into a String timestamp' do

      t = Time.local(2015, 12, 19, 13, 30, 00)

      expect(Flor.tstamp(t)).to eq('20151219.133000000000')
    end
  end

  describe '.to_time' do

    it 'turns a Flor timestamp into a Time instance'
  end
end

