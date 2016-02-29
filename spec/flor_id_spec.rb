
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
end

