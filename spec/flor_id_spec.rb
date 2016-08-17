
#
# specifying flor
#
# Tue Mar  1 07:10:14 JST 2016
#

require 'spec_helper'


describe Flor do

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

  describe '.parent_nid' do

    it 'works' do

      expect(Flor.parent_nid('0')).to eq(nil)
      expect(Flor.parent_nid('0_1')).to eq('0')
      expect(Flor.parent_nid('0_1_9')).to eq('0_1')
      expect(Flor.parent_nid('0_1_9-6')).to eq('0_1-6')
    end

    it 'works when remove_subnid=true' do

      expect(Flor.parent_nid('0-7', true)).to eq(nil)
      expect(Flor.parent_nid('0_1', true)).to eq('0')
      expect(Flor.parent_nid('0_1_9', true)).to eq('0_1')
      expect(Flor.parent_nid('0_1_9-6', true)).to eq('0_1')
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

  describe '.child_nid(nid, i)' do

    it 'adds the given id to make a new nid' do

      expect(
        Flor.child_nid('0_0_0', 11)
      ).to eq(
        '0_0_0_11'
      )
    end
  end

  describe '.child_nid(nid, i, sub)' do

    it 'ads the given id and the given sub to make a new nid' do

      expect(
        Flor.child_nid('0_0_0', 11, 0)
      ).to eq(
        '0_0_0_11'
      )
      expect(
        Flor.child_nid('0_0', 12, 1)
      ).to eq(
        '0_0_12-1'
      )
    end
  end

  describe '.is_nid?(s)' do

    it 'returns true when given a flor nid' do

      expect(Flor.is_nid?('0_0')).to eq(true)
      expect(Flor.is_nid?('0_0-1')).to eq(true)
      expect(Flor.is_nid?('0_95-1')).to eq(true)
    end

    it 'returns false else' do

      expect(Flor.is_nid?('')).to eq(false)
      expect(Flor.is_nid?('a0_0')).to eq(false)
    end
  end

  describe '.domain(s)' do

    it 'returns the domain for exid s' do

      exid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba"

      expect(Flor.domain(exid)).to eq('domain0.xx.yy.z_z')
    end

    it 'returns the domain for nid s' do

      nid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba-0_0"

      expect(Flor.domain(nid)).to eq('domain0.xx.yy.z_z')

      nid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba-0_0_0-12"

      expect(Flor.domain(nid)).to eq('domain0.xx.yy.z_z')
    end

    it 'returns nil when it cannot find the domain' do

      s = "unit0-domain0 .xx.yy.z_z-20160816.0627.kizarofeba-0_0_0-12"

      expect(Flor.domain(s)).to eq(nil)
    end
  end

  describe '.unit(s)' do

    it 'returns the unit for exid s' do

      exid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba"

      expect(Flor.unit(exid)).to eq('unit0')
    end

    it 'returns the unit for nid s' do

      nid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba-0_0"

      expect(Flor.unit(nid)).to eq('unit0')

      nid = "domain0.xx.yy.z_z-unit0-20160816.0627.kizarofeba-0_0_0-12"

      expect(Flor.unit(nid)).to eq('unit0')
    end

    it 'returns nil when it cannot find the unit' do

      s = "unit0-domain0 .xx.yy.z_z-20160816.0627.kizarofeba-0_0_0-12"

      expect(Flor.unit(s)).to eq(nil)
    end
  end
end

